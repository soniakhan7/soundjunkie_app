//
//  WebViewController.swift
//  MusicPlayer
//
//  Created by Sonia Khan on 4/22/23.
//

import Foundation
import WebKit

class WebViewController: UIViewController {
    
    
    @IBOutlet weak var WVSite: WKWebView!
    var receivedURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = receivedURL
        let request = URLRequest(url: url!)
        WVSite.load(request)
    }
}
