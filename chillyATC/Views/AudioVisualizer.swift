import SwiftUI

struct AudioVisualizer: View {
    let isActive: Bool
    @State private var animation = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.green)
                    .frame(width: 3)
                    .frame(height: 20)
                    .scaleEffect(y: animation ? randomHeight(for: index) : 0.3, anchor: .bottom)
                    .animation(
                        isActive ? Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1) : nil,
                        value: animation
                    )
            }
        }
        .onChange(of: isActive) { oldValue, newValue in
            animation = newValue
        }
        .onAppear {
            animation = isActive
        }
        .opacity(isActive ? 1.0 : 0.3) // Dim the visualizer when inactive
    }
    
    private func randomHeight(for index: Int) -> CGFloat {
        let heights: [CGFloat] = [0.7, 1.0, 0.8, 1.0, 0.7]
        return heights[index]
    }
}

#Preview {
    AudioVisualizer(isActive: true)
} 