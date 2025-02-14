//
//  ContentView.swift
//  chillyATC
//
//  Created by Olzhas on 13/02/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
        MainView(audioManager: audioManager)
    }
}

// MARK: - Main View
private struct MainView: View {
    let audioManager: AudioManager
    @State private var showingInfo = false
    
    var body: some View {
        ZStack {
            Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? .black : .white
            })
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    HeaderView(audioManager: audioManager)
                    
                    Button(action: { showingInfo = true }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                            .font(.system(size: 22))
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Airport Selection Section with proper spacing
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 8) {
                                Text("AIRPORT SELECT")
                                    .sectionHeaderStyle()
                                
                                Image(systemName: "airplane")
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            
                            AirportSelectionView(audioManager: audioManager)
                                .padding(.horizontal)
                        }
                        
                        // Audio Controls Section with more top spacing
                        VStack(alignment: .leading, spacing: 20) {
                            Text("AUDIO CONTROLS")
                                .sectionHeaderStyle()
                                .padding(.horizontal)
                                .padding(.top, 12) // Add extra top padding
                            
                            AudioControlsView(audioManager: audioManager)
                                .padding(.horizontal)
                        }
                        .padding(.top, 24) // Increase top padding to create more space
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingInfo) {
            InfoView()
        }
    }
}

// MARK: - Header View
private struct HeaderView: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        HStack(spacing: 24) {
            StatusIndicator(
                isActive: audioManager.isATCPlaying && audioManager.isATCPowered,
                color: .green,
                text: "ATC"
            )
            StatusIndicator(
                isActive: audioManager.isMusicPlaying && audioManager.isMusicPowered,
                color: .blue,
                text: "MUSIC"
            )
            if audioManager.isLoading {
                ProgressView()
                    .tint(.green)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Airport Selection View
private struct AirportSelectionView: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Current Airport Status Card
            CurrentAirportCard(
                cityName: currentCity,
                airportName: audioManager.selectedFeed?.name ?? "",
                statusText: statusText,
                statusColor: statusColor
            )
            .zIndex(1)
            
            // Inline picker view for selecting an airport.
            AirportPickerSection(audioManager: audioManager)
                .frame(height: 90) // Adjust this height as needed
                .padding(.top, 8)
                .zIndex(0)
        }
        .padding(.vertical, 16)
    }
    
    private var currentCity: String {
        audioManager.selectedFeed?.city ?? audioManager.atcFeeds[0].city
    }
    
    private var statusText: String {
        if !audioManager.isATCPowered {
            return "OFFLINE"
        }
        return audioManager.streamStatus[currentCity] ?? false ? "LIVE" : "OFFLINE"
    }
    
    private var statusColor: Color {
        if !audioManager.isATCPowered {
            return .red
        }
        return audioManager.streamStatus[currentCity] ?? false ? .green : .red
    }
}

// MARK: - Current Airport Card
private struct CurrentAirportCard: View {
    let cityName: String
    let airportName: String
    let statusText: String
    let statusColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(cityName)
                    .font(.system(.title3, design: .monospaced))
                    .foregroundColor(Color(UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark ? .white : .black
                    }))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                Text(statusText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(statusColor, lineWidth: 1)
                    )
            }
            
            if !airportName.isEmpty {
                Text(airportName)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Color(.secondaryLabel))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ?
                        UIColor(white: 0.1, alpha: 1.0) :
                        UIColor.systemBackground
                }))
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 10, y: 2)
        )
    }
}

// MARK: - Airport Picker Section
private struct AirportPickerSection: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ?
                        UIColor(white: 0.1, alpha: 1.0) :
                        UIColor.systemBackground
                }))
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 10, y: 2)
            
            ATCPickerView(
                feeds: audioManager.atcFeeds,
                selectedFeed: Binding(
                    get: { audioManager.selectedFeed ?? audioManager.atcFeeds[0] },
                    set: { newFeed in
                        if audioManager.isATCPowered {
                            audioManager.playATC(feed: newFeed)
                        } else {
                            audioManager.selectedFeed = newFeed
                        }
                    }
                )
            )
        }
    }
}

// MARK: - Audio Controls View
private struct AudioControlsView: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 16) {
            AudioControlPanel(
                title: "ATC",
                isActive: audioManager.isATCPlaying,
                isPowered: audioManager.isATCPowered,
                color: .green,
                volume: Binding(
                    get: { audioManager.atcVolume },
                    set: { audioManager.updateATCVolume($0) }
                ),
                onPowerToggle: audioManager.toggleATC
            )
            
            AudioControlPanel(
                title: "AMBIENT MUSIC",
                isActive: audioManager.isMusicPlaying,
                isPowered: audioManager.isMusicPowered,
                color: .blue,
                volume: Binding(
                    get: { audioManager.musicVolume },
                    set: { audioManager.updateMusicVolume($0) }
                ),
                onPowerToggle: audioManager.toggleMusicPower
            )
        }
    }
}

// MARK: - Supporting Views
struct StatusIndicator: View {
    let isActive: Bool
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isActive ? color : Color(.systemGray4))
                .frame(width: 8, height: 8)
            
            Text(text)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(isActive ? color : Color(.systemGray2))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ? 
                        UIColor.gray.withAlphaComponent(0.1) :
                        UIColor.systemGray6
                }))
        )
    }
}

struct AirportCell: View {
    let feed: ATCFeed
    let isSelected: Bool
    let isOnline: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Airport Icon
                Image(systemName: "airplane")
                    .foregroundColor(isSelected ? .green : .gray)
                
                // Airport Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(feed.name)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(isSelected ? .green : .white)
                    
                    Text("\(feed.city), \(feed.state ?? feed.country)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Live Indicator
                LiveIndicator(isOnline: isOnline)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.green : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AudioControlPanel: View {
    let title: String
    let isActive: Bool
    let isPowered: Bool
    let color: Color
    let volume: Binding<Float>
    let onPowerToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .sectionHeaderStyle()
            
            HStack(spacing: 24) {
                AudioWaveform(isActive: isPowered, color: color)
                    .frame(width: 60, height: 30)
                
                PowerToggle(isOn: isPowered, color: color, onToggle: onPowerToggle)
                    .frame(width: 51)
                
                VolumeSlider(value: volume, color: color)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ?
                        UIColor(white: 0.1, alpha: 1.0) :
                        UIColor.systemBackground
                }))
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.05), radius: 10, y: 2)
        )
    }
}

struct AudioWaveform: View {
    let isActive: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5) { index in
                WaveBar(
                    index: index,
                    isActive: isActive,
                    color: color.opacity(isActive ? 1 : 0.3)
                )
            }
        }
    }
}

private struct WaveBar: View {
    let index: Int
    let isActive: Bool
    let color: Color
    @State private var height: CGFloat = 4
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 3, height: height)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
            .onAppear {
                if isActive {
                    startAnimation()
                }
            }
    }
    
    private func startAnimation() {
        withAnimation(
            .easeInOut(duration: 0.6)
            .repeatForever()
            .delay(Double(index) * 0.1)
        ) {
            height = heightForBar(index: index)
        }
    }
    
    private func stopAnimation() {
        withAnimation(.easeOut(duration: 0.2)) {
            height = 4 // Reset to minimum height when inactive
        }
    }
    
    private func heightForBar(index: Int) -> CGFloat {
        let heights: [CGFloat] = [15, 25, 20, 25, 15]
        return heights[index]
    }
}

struct LiveIndicator: View {
    let isOnline: Bool
    
    var body: some View {
        Text("LIVE")
            .font(.system(.caption, design: .monospaced))
            .foregroundColor(.green)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.green, lineWidth: 1)
            )
            .opacity(isOnline ? 1 : 0.3)
    }
}

struct PowerToggle: View {
    @State private var isToggled: Bool
    let isOn: Bool
    let color: Color
    let onToggle: () -> Void
    
    init(isOn: Bool, color: Color, onToggle: @escaping () -> Void) {
        self.isOn = isOn
        self._isToggled = State(initialValue: isOn)
        self.color = color
        self.onToggle = onToggle
    }
    
    var body: some View {
        Toggle("", isOn: Binding(
            get: { isOn },
            set: { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isToggled = !isToggled
                    onToggle()
                }
            }
        ))
        .labelsHidden()
        .toggleStyle(PowerToggleStyle(color: color))
    }
}

struct PowerToggleStyle: ToggleStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(configuration.isOn ? color : Color.gray.opacity(0.3))
            .frame(width: 50, height: 30)
            .overlay(
                Circle()
                    .fill(Color.white)
                    .padding(4)
                    .offset(x: configuration.isOn ? 10 : -10)
            )
            .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    configuration.isOn.toggle()
                }
            }
    }
}

struct VolumeSlider: View {
    let value: Binding<Float>
    let color: Color
    
    var body: some View {
        Slider(value: value)
            .accentColor(color)
    }
}

// MARK: - Style Extensions
extension View {
    func sectionHeaderStyle() -> some View {
        self.font(.system(.subheadline, design: .monospaced))
            .foregroundColor(.gray)
    }
}

#Preview {
    ContentView()
}
