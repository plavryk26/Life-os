import SwiftUI
import WebKit

// MARK: - WebView Wrapper

struct WebView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Enable localStorage & IndexedDB in file:// context
        config.preferences.javaScriptEnabled = true
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")

        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = context.coordinator
        wv.uiDelegate = context.coordinator
        wv.scrollView.bounces = false
        wv.scrollView.contentInsetAdjustmentBehavior = .never
        wv.isOpaque = false
        wv.backgroundColor = .clear

        // Camera / mic permissions for barcode scanner
        wv.configuration.allowsInlineMediaPlayback = true

        return wv
    }

    func updateUIView(_ wv: WKWebView, context: Context) {
        let req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        wv.load(req)
    }

    // MARK: Coordinator
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {

        // Allow camera access prompt
        @available(iOS 15.0, *)
        func webView(
            _ webView: WKWebView,
            requestMediaCapturePermissionFor origin: WKSecurityOrigin,
            initiatedByFrame frame: WKFrameInfo,
            type: WKMediaCaptureType,
            decisionHandler: @escaping (WKPermissionDecision) -> Void
        ) {
            decisionHandler(.grant)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Inject safe-area & iOS-style overscroll prevention
            let js = """
            document.documentElement.style.setProperty(
              '--sat', 'env(safe-area-inset-top,0px)');
            document.documentElement.style.setProperty(
              '--sab', 'env(safe-area-inset-bottom,0px)');
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("[LifeOS] Navigation failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    // Resolve index.html bundled next to the .xcodeproj
    private var indexURL: URL {
        // 1. Try bundle (when index.html is added as a resource)
        if let bundled = Bundle.main.url(forResource: "index", withExtension: "html") {
            return bundled
        }
        // 2. Fall back to repo root (for Simulator / development)
        let repoRoot = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()   // LifeOS/
            .deletingLastPathComponent()   // ios/
            .deletingLastPathComponent()   // cyborg-os/
        return repoRoot.appendingPathComponent("index.html")
    }

    var body: some View {
        WebView(url: indexURL)
            .ignoresSafeArea()
            .preferredColorScheme(.dark)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
