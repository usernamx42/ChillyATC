import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ? .black : .white
                })
                .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 8) {
                        Text("About Chilly ATC")
                            .font(.system(.title2, design: .monospaced))
                            .foregroundColor(Color(.label))
                        
                        Image(systemName: "airplane")
                            .foregroundColor(Color(.secondaryLabel))
                            .font(.system(size: 20))
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Purpose")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(Color(.secondaryLabel))
                        
                        Text("Chilly ATC is designed to help you enter a flow state by combining real-time Air Traffic Control communications with ambient background music. This unique audio combination creates an ideal environment for focus and productivity.")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(Color(.label))
                            .opacity(0.8)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("© 2025 Olzhas Yergaliyev")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text("y.olzhas@gmail.com")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text("All rights reserved")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

#Preview {
    InfoView()
} 