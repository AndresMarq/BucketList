//
//  Bundle-Filemanager.swift
//  BucketList
//
//  Created by Andres Marquez on 2021-08-04.
//

import Foundation

extension Bundle {
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func writeAndRead() {
        let str = "Test Message"
                let url = self.getDocumentsDirectory().appendingPathComponent("message.txt")

                do {
                    try str.write(to: url, atomically: true, encoding: .utf8)
                    let input = try String(contentsOf: url)
                    print(input)
                } catch {
                    print(error.localizedDescription)
                }
    }
}
