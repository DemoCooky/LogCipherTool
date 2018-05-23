//
//  HiLogProcessor.swift
//  HiLogProcessor
//
//  Created by Wang Bo on 2018/4/22.
//  Copyright © 2018年 Wang Bo. All rights reserved.
//

import Cocoa

// Note:
//
//  1. 从日志平台获取的一个 tar 压缩包
//  2. tar 包内是多个 tar 压缩包，每一个解压后获得一个日志文件
//
//

class HiLogProcessor:NSObject {
    
   // private override init() {}
    
    /// 对指定路径的压缩文件做解压缩处理
    ///
    /// - Parameter url: 目标路径
    class func processor(at url: URL) -> (Array<String>) {
        
        /// 执行 shell 命令
        let excute: ([String]) -> Swift.Void = { commands in
            do {
                try shellOut(to: commands)
            } catch  {
                print(error)
            }
        }
        
        let fileManager = FileManager.default
        fileManager.changeCurrentDirectoryPath(url.deletingLastPathComponent().absoluteString)
        
        // url: file:///Users/wangbo/Downloads/8145191757677-16.tar
        let newDir = url.deletingPathExtension().lastPathComponent
        if fileManager.fileExists(atPath: "\(fileManager.currentDirectoryPath)/\(newDir)") {
            try? fileManager.removeItem(atPath: "\(fileManager.currentDirectoryPath)/\(newDir)")
        }
        
        let makeNewDir = "mkdir \(newDir)"
        let extract = "tar -zxvf \(url.path) -C \(newDir)"
        // 解压最外层压缩包
        excute([makeNewDir, extract])
        
        // 解压内层压缩包
        if let items = fileManager.enumerator(atPath: "\(fileManager.currentDirectoryPath)/\(newDir)") {
            for item in items {
                let cdNewDir = "cd \(newDir)"
                let extract = "tar -zxvf \(item)"
                let delete = "rm \(item)"

                excute([cdNewDir, extract, delete])
            }
        }
        // 日志解密
        var filePathArray = [String]()
        if let items = fileManager.enumerator(atPath: "\(fileManager.currentDirectoryPath)/\(newDir)") {
            for item in items {
                if let path = item as? String, path.contains(".log") {
                    let filePath = "\(fileManager.currentDirectoryPath)/\(newDir)/\(path)"
                    filePathArray.append(filePath)
                    print(filePath)
                }
            }
        }
        
        return filePathArray.sorted {
            return $0 < $1
        }
    }
    
    class func decode(at path: String) {
        
        
    }

}
