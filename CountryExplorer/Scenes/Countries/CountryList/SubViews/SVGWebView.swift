//
//  SVGWebView.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/26/25.
//

import SwiftUI
import WebKit

struct SVGWebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false  // Disable scrolling
        webView.isOpaque = false  // Make background transparent
        webView.backgroundColor = .clear

        
        if let url = URL(string: urlString) {
            let htmlString = """
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <style>
                    html, body { margin: 0; padding: 0; height: 100%; width: 100%; display: flex; justify-content: center; align-items: center; }
                    img { width: 100vw; height: 100vh; object-fit: contain; }
                </style>
            </head>
            <body>
                <img src="\(url.absoluteString)" />
            </body>
            </html>
            """
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
