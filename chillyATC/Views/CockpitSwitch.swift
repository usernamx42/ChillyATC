import SwiftUI

struct CockpitSwitch: View {
    let isOn: Binding<Bool>
    let label: String
    var isEnabled: Bool = true
    
    var body: some View {
        VStack(spacing: 8) {
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .frame(width: 51, height: 31) // Standard iOS toggle size
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            Color(UIColor { trait in
                                if trait.userInterfaceStyle == .light {
                                    // Use a light gray background in light mode.
                                    return UIColor(white: 0.9, alpha: 1.0)
                                } else {
                                    // Retain the dark background for dark mode.
                                    return UIColor(white: 0.2, alpha: 1.0)
                                }
                            })
                        )
                        .shadow(
                            color: Color(UIColor { trait in
                                if trait.userInterfaceStyle == .light {
                                    // Softer shadow in light mode.
                                    return UIColor(white: 0, alpha: 0.2)
                                } else {
                                    return UIColor(white: 0, alpha: 0.5)
                                }
                            }),
                            radius: 2
                        )
                )
                .disabled(!isEnabled)
                .opacity(isEnabled ? 1 : 0.5)
            
            Text(label)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(isEnabled ? .primary : .gray)
        }
    }
}

#Preview {
    CockpitSwitch(
        isOn: .constant(true),
        label: "TEST",
        isEnabled: true
    )
} 