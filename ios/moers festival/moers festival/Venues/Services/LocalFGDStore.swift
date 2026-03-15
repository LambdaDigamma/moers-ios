//
//  LocalFGDStore.swift
//  moers festival
//
//  Created by Lennart Fischer on 09.05.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import Foundation

public class LocalFGDStore {
    
    public static let fileManager: FileManager = .default
    
    public static func directory() -> URL? {
        
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fgdDirectory = documentsDirectory.appendingPathComponent("currentFGD")
        
        return fgdDirectory
        
    }
    
    public static func createDirectoryIfNeeded() {
        
        guard let directory = directory() else { return }
        
        if !fileManager.fileExists(atPath: directory.path) {
            do {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
        
    }
    
    public static func getFileUrl(key: String) -> URL? {
        
        return directory()?.appendingPathComponent("\(key).geojson")
        
    }
    
}
