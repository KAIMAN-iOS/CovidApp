//
//  Storage.swift
//  CovidApp
//
//  Created by jerome on 31/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation

typealias Handler<T> = (Result<T>) -> Void

protocol ReadableStorage {
    func fetchValue(for key: String) throws -> Data
    func fetchValue(for key: String, handler: @escaping Handler<Data>)
}

protocol WritableStorage {
    func save(value: Data, for key: String) throws
    func save(value: Data, for key: String, handler: @escaping Handler<Data>)
}

typealias Storage = ReadableStorage & WritableStorage
enum StorageError: Error {
    case notFound
    case cantWrite(Error)
}

class DiskStorage {
    private let queue: DispatchQueue
    private let fileManager: FileManager
    private let path: URL
    
    init(
        path: URL,
        queue: DispatchQueue = .init(label: "DiskCache.Queue"),
        fileManager: FileManager = FileManager.default
    ) {
        self.path = path
        self.queue = queue
        self.fileManager = fileManager
    }
}

extension DiskStorage: WritableStorage {
    func save(value: Data, for key: String) throws {
        let url = path.appendingPathComponent(key)
        do {
            try self.createFolders(in: url)
            try value.write(to: url, options: .atomic)
        } catch {
            throw StorageError.cantWrite(error)
        }
    }
    
    func save(value: Data, for key: String, handler: @escaping Handler<Data>) {
        queue.async {
            do {
                try self.save(value: value, for: key)
                handler(.success(value))
            } catch {
                handler(.failure(error))
            }
        }
    }
}

extension DiskStorage {
    private func createFolders(in url: URL) throws {
        let folderUrl = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: folderUrl.path) {
            try fileManager.createDirectory(
                at: folderUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
}

extension DiskStorage: ReadableStorage {
    func fetchValue(for key: String) throws -> Data {
        let url = path.appendingPathComponent(key)
        guard let data = fileManager.contents(atPath: url.path) else {
            throw StorageError.notFound
        }
        return data
    }
    
    func fetchValue(for key: String, handler: @escaping Handler<Data>) {
        queue.async {
            do {
                let res = try self.fetchValue(for: key)
                handler(.success(res))
                } catch (let error) {
                    handler(.failure(error))
                }
        }
    }
}
/* USE =
 struct Timeline: Codable {
 let tweets: [String]
 }
 
 let path = URL(fileURLWithPath: NSTemporaryDirectory())
 let disk = DiskStorage(path: path)
 let storage = CodableStorage(storage: disk)
 
 let timeline = Timeline(tweets: ["Hello", "World", "!!!"])
 try storage.save(timeline, for: "timeline")
 let cached: Timeline = try storage.fetch(for: "timeline")
 */
class CodableStorage {
    private let storage: DiskStorage
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(
        storage: DiskStorage,
        decoder: JSONDecoder = .init(),
        encoder: JSONEncoder = .init()
    ) {
        self.storage = storage
        self.decoder = decoder
        self.encoder = encoder
    }
    
    func fetch<T: Decodable>(for key: String) throws -> T {
        let data = try storage.fetchValue(for: key)
        return try decoder.decode(T.self, from: data)
    }
    
    func save<T: Encodable>(_ value: T, for key: String) throws {
        let data = try encoder.encode(value)
        try storage.save(value: data, for: key)
    }
}

struct DataStorage {
    private static let instance = DataStorage()
    private let storage = CodableStorage(storage: DiskStorage(path: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])))
    init() {}
    
    func fetch<T: Decodable>(for key: String) throws -> T {
        return try storage.fetch(for: key)
    }
    
    func save<T: Encodable>(_ value: T, for key: String) throws {
        try storage.save(value, for: key)
    }
    
    func save(_ answers: Answers) throws {
        try storage.save(answers, for: "Answers")
    }
    
    func fecthAnswers() throws -> Answers? {
        return nil
    }
    
    func save(_ metrics: Metrics) throws {
        
    }
    
    func fecthMetrics() throws -> [Metrics] {
        return []
    }
}
