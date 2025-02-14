import AVFoundation
import Combine

enum AudioPlayerError: Error {
    case invalidURL
    case playbackFailed(Error)
    case sessionSetupFailed(Error)
}

@MainActor
class AudioManager: ObservableObject {
    private var atcPlayer: AVPlayer?
    private var musicPlayer: AVPlayer?
    private var audioSession: AVAudioSession
    private var playerItemStatusObserver: AnyCancellable?
    private var timeControlStatusObserver: AnyCancellable?
    
    @Published var atcVolume: Float = 0.5
    @Published var musicVolume: Float = 0.5
    @Published var isATCPlaying = false
    @Published var isMusicPlaying = true
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var streamStatus: [String: Bool] = [:] // city: isOnline
    @Published var isATCPowered = false
    @Published var isMusicPowered = true
    
    let atcFeeds: [ATCFeed] = [
        ATCFeed(
            name: "KSFO Tower",
            description: "Tower",
            city: "San Francisco",
            state: "California",
            country: "United States",
            streamURL: "ksfo_twr"
        ),
        ATCFeed(
            name: "RJAA Approach",
            description: "Approach",
            city: "Tokyo",
            state: nil,
            country: "Japan",
            streamURL: "rjaa_app_s"
        ),
        ATCFeed(
            name: "CYYZ Tower",
            description: "Tower",
            city: "Toronto",
            state: "Ontario",
            country: "Canada",
            streamURL: "cyyz7"
        ),
        ATCFeed(
            name: "MROC Del/Gnd/Twr/App/Center/Misc",
            description: "Tower",
            city: "San Jose",
            state: nil,
            country: "Costa Rica",
            streamURL: "mroc"
        ),
        ATCFeed(
            name: "KJFK Gnd/Twr",
            description: "Ground/Tower",
            city: "New York",
            state: "New York",
            country: "United States",
            streamURL: "kjfk9_s"
        ),
        ATCFeed(
            name: "RCSS Tower/App/Dep",
            description: "Tower/App/Dep",
            city: "Taipei",
            state: nil,
            country: "Taiwan",
            streamURL: "rcss2"
        ),
        ATCFeed(
            name: "KLAX Tower (South) #1",
            description: "Tower",
            city: "Los Angeles",
            state: "California",
            country: "United States",
            streamURL: "klax4"
        ),
        ATCFeed(
            name: "UAAA Tower/Approach",
            description: "Tower/Approach",
            city: "Almaty",
            state: nil,
            country: "Kazakhstan",
            streamURL: "uaaa"
        ),
        ATCFeed(
            name: "SPQU Ground/Tower",
            description: "Tower",
            city: "Arequipa",
            state: nil,
            country: "Peru",
            streamURL: "spqu2_gta"
        ),
        ATCFeed(
            name: "PHNL Tower (Primary)",
            description: "Tower",
            city: "Honolulu",
            state: "Hawaii",
            country: "United States",
            streamURL: "phnl1_twr_pri"
        )
    ]
    
    var selectedFeed: ATCFeed?
    
    init() {
        audioSession = AVAudioSession.sharedInstance()
        setupAudioSession()
        // Automatically load the Soma music stream if music power is enabled.
        // Delay the call slightly to ensure the audio session is active.
        if isMusicPowered {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
               self.playMusic()
            }
        }
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Failed to setup audio: \(error.localizedDescription)"
        }
    }
    
    func playATC(feed: ATCFeed) {
        selectedFeed = feed
        isLoading = true
        
        let urlString = "https://www.liveatc.net/play/\(feed.streamURL).pls"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid stream URL"
            isLoading = false
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        atcPlayer = AVPlayer(playerItem: playerItem)
        atcPlayer?.volume = atcVolume
        
        playerItemStatusObserver = playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .readyToPlay:
                    if self.isATCPowered {
                        self.atcPlayer?.play()
                        self.isATCPlaying = true
                        self.streamStatus[feed.city] = true
                    }
                    self.isLoading = false
                case .failed:
                    if let error = playerItem.error {
                        self.errorMessage = "Failed to load stream: \(error.localizedDescription)"
                    } else {
                        self.errorMessage = "Failed to load stream"
                    }
                    self.isLoading = false
                    self.isATCPlaying = false
                    self.streamStatus[feed.city] = false
                default:
                    break
                }
            }
    }
    
    func playMusic() {
        isLoading = true
        
        // Cancel any existing observers and player
        playerItemStatusObserver?.cancel()
        musicPlayer?.pause()
        musicPlayer = nil
        
        // Use a direct MP3 stream URL (more reliable and avoids plist issues)
        let musicStreamURL = "https://ice1.somafm.com/groovesalad-128-mp3"
        
        guard let url = URL(string: musicStreamURL) else {
            errorMessage = "Invalid music stream URL"
            isLoading = false
            return
        }
        
        // Create the player item directly
        let playerItem = AVPlayerItem(url: url)
        musicPlayer = AVPlayer(playerItem: playerItem)
        musicPlayer?.volume = musicVolume
        
        // Observe player item status
        playerItemStatusObserver = playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                Task { @MainActor in
                    switch status {
                    case .readyToPlay:
                        if self.isMusicPowered {
                            self.musicPlayer?.play()
                            self.isMusicPlaying = true
                        }
                        self.isLoading = false
                        
                    case .failed:
                        if let error = playerItem.error {
                            print("Stream error: \(error.localizedDescription)")
                            self.errorMessage = "Stream error: \(error.localizedDescription)"
                        }
                        self.isLoading = false
                        self.isMusicPlaying = false
                        // Try fallback stream if primary fails
                        self.tryFallbackStream()
                        
                    default:
                        break
                    }
                }
            }
    }
    
    private func tryFallbackStream() {
        // Use an alternative direct MP3 stream URL as fallback
        let fallbackURL = "https://ice2.somafm.com/groovesalad-128-mp3"
        
        guard let url = URL(string: fallbackURL) else { return }
        
        let playerItem = AVPlayerItem(url: url)
        musicPlayer?.replaceCurrentItem(with: playerItem)
        
        playerItemStatusObserver = playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                Task { @MainActor in
                    if status == .readyToPlay && self.isMusicPowered {
                        self.musicPlayer?.play()
                        self.isMusicPlaying = true
                    }
                }
            }
    }
    
    func toggleATC() {
        isATCPowered.toggle()
        if isATCPowered {
            // When powering on, try to play the currently selected feed
            if let currentFeed = selectedFeed {
                playATC(feed: currentFeed)
            } else if let firstFeed = atcFeeds.first {
                // If no feed is selected, try the first available one
                playATC(feed: firstFeed)
            }
        } else {
            // If powered off, always pause
            atcPlayer?.pause()
            isATCPlaying = false
        }
    }
    
    func toggleMusicPower() {
        isMusicPowered.toggle()
        if isMusicPowered {
            // If we're turning power on and don't have a stream playing, start it
            if musicPlayer?.currentItem == nil {
                playMusic()
            } else {
                musicPlayer?.play()
                isMusicPlaying = true
            }
        } else {
            musicPlayer?.pause()
            isMusicPlaying = false
        }
    }
    
    func toggleMusic() {
        if !isMusicPowered {
            return  // Don't toggle if power is off
        }
        if isMusicPlaying {
            musicPlayer?.pause()
        } else {
            musicPlayer?.play()
        }
        isMusicPlaying.toggle()
    }
    
    func updateATCVolume(_ volume: Float) {
        atcVolume = volume
        atcPlayer?.volume = volume
    }
    
    func updateMusicVolume(_ volume: Float) {
        musicVolume = volume
        musicPlayer?.volume = volume
    }
    
    func cleanup() {
        atcPlayer?.pause()
        musicPlayer?.pause()
        playerItemStatusObserver?.cancel()
        timeControlStatusObserver?.cancel()
        try? audioSession.setActive(false)
    }
} 
