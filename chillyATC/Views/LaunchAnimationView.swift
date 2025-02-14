import SwiftUI

struct LaunchAnimationView: View {
    @State private var showTitle = false
    @State private var showIcons = false
    @State private var iconRotation = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // App Name
                Text("CHILLY ATC")
                    .font(.system(size: 24, weight: .regular, design: .monospaced))
                    .foregroundColor(.green)
                    .opacity(showTitle ? 1 : 0)
                    .scaleEffect(showTitle ? 1 : 0.5)
                
                HStack(spacing: 12) {
                    // Airplane icon
                    Image(systemName: "airplane")
                        .symbolEffect(.bounce, options: .repeating, value: iconRotation)
                        .foregroundColor(.green)
                    
                    // Speaker icon
                    Image(systemName: "speaker.wave.2")
                        .symbolEffect(.bounce, options: .repeating, value: iconRotation)
                        .foregroundColor(.green)
                }
                .font(.system(size: 24))
                .opacity(showIcons ? 1 : 0)
                .scaleEffect(showIcons ? 1 : 0.5)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                showTitle = true
            }
            
            withAnimation(.easeInOut(duration: 0.6).delay(0.3)) {
                showIcons = true
            }
            
            withAnimation(.easeInOut(duration: 1.2).delay(0.6)) {
                iconRotation.toggle()
            }
        }
    }
} 