//
//  Cache.swift
//  app
//
//  Created by Rody Davis on 6/17/21.
//

import Foundation

class AppBundle {
    lazy var prefs: WebConfig = WebConfig()
    let appSup = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    
    init(prefs: WebConfig) {
        self.prefs = prefs
    }
   
    func get() -> String {
        // Start remote download
        self.download()
        
        #if DEBUG
        #else
        // Search for cached bundle
        do {
            let url = self.appSup.appendingPathComponent(self.prefs.bundle).appendingPathExtension("js")
            let bundle: String = try String(contentsOfFile: url.path)
            return bundle
        } catch {
            print("Cached bundle not found", error)
        }
        #endif
        
        // Fallback to included bundle
        do {
            let url = Bundle.main.url(forResource: self.prefs.bundle, withExtension: "js", subdirectory: "build")!
            let bundle: String = try String(contentsOfFile: url.path)
            self.save(content: bundle)
            return bundle
        } catch {
            print("Local bundle not found", error)
        }
        
        // No bundle included
        return ""
    }

    func save(content: String) {
        let fileManager = FileManager.default
        
        let bundleUrl = self.appSup.appendingPathComponent(self.prefs.bundle).appendingPathExtension("js")
        
        // Check if Application Support Exists
        if !fileManager.fileExists(atPath: self.appSup.path) {
            do {
                try fileManager.createDirectory(
                    at: self.appSup,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                print("Could not create app support directory", error)
            }
        }
        
        // Fallback to bundle included at compile time
        if fileManager.fileExists(atPath: bundleUrl.path) {
            do {
                try fileManager.removeItem(at: bundleUrl)
            } catch {
                print("Could not remove existing bundle", error)
            }
        }
        
        // Update the bundle
        do {
            try content.write(to: bundleUrl, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Error updating bundle", error)
        }
    }

    func download() {
        if self.prefs.url.isEmpty { return }
        
        if let url = URL(string: self.prefs.url + "/" + self.prefs.bundle) {
            let key = "last-bundle-update";
            
            // Check if the bundle has already been downloaded
            if let value = UserDefaults.standard.object(forKey: key) as? Date {
                if Calendar.current.daysSince(date: value) ?? -1 < self.prefs.cacheDays {
                    return
                }
            }
            
            // Try downloading a new bundle from the network
            let downloadTask = URLSession.shared.downloadTask(with: url) { (tempUrl, response, error) in
                if let tempFileUrl = tempUrl {
                    do {
                        let remoteBundle = try String(contentsOf: tempFileUrl)
                        self.save(content: remoteBundle)
                        UserDefaults.standard.set(Date(), forKey: key)
                    } catch {
                        print("Error downloading bundle", error)
                    }
                }
            }
            downloadTask.resume()
        }
    }

}
