import SwiftUI

struct ContentView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "apple.logo")
                .font(.system(size: 56))
            Text("Hello, \(platformName)!")
                .font(.title)
            Button("Tapped \(count) times") { count += 1 }
                .buttonStyle(.borderedProminent)
        }
        .padding(40)
    }

    /// The OS this build is running on; iPhone and iPad share one binary.
    private var platformName: String {
        #if os(macOS)
        "macOS"
        #else
        UIDevice.current.userInterfaceIdiom == .pad ? "iPadOS" : "iOS"
        #endif
    }
}

#Preview {
    ContentView()
}
