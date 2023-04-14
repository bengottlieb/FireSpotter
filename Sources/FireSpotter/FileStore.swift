//
//  FileStore.swift
//  
//
//  Created by Ben Gottlieb on 3/19/23.
//

import Foundation
import FirebaseStorage
import CrossPlatformKit
import Suite

public struct ImageKind: Equatable {
	public let rawValue: String
	
	public init(rawValue: String) {
		self.rawValue = rawValue
	}
	
	func path(for name: String) -> String {
		rawValue + "/" + name
	}
	
	static public let avatar = ImageKind(rawValue: "avatar")
	static public let userSubmitted = ImageKind(rawValue: "userSubmitted")
}

public class FileStore {
	public static let instance = FileStore()
	public var session = URLSession.shared
	
	public static var maxUploadedImageSize = CGSize(width: 500, height: 500)
	
	enum StorageError: Error { case rootStorageNotAllowed, noImageData, failedToResizeImage }
	
	@discardableResult public func upload(image: UXImage, kind: ImageKind = .userSubmitted, to path: String, quality: Double = 0.9, maxSize: CGSize = FileStore.maxUploadedImageSize) async throws -> FirebaseStorage.StorageMetadata {
		var uploadedImage = image
		if image.size.width > maxSize.width || image.size.width > maxSize.width {
			guard let resized = image.resized(to: maxSize, trimmed: true, changeScaleTo: 1) else { throw StorageError.failedToResizeImage }
			uploadedImage = resized
		}
		
		guard let data = quality == 1.0 ? uploadedImage.pngData() : uploadedImage.jpegData(compressionQuality: quality) else { throw StorageError.noImageData }
		let contentType = quality == 1.0 ? "image/png" : "image/jpeg"
		
		return try await upload(data: data, to: kind.path(for: path), contentType: contentType)
	}
	
	@discardableResult public func upload(data: Data, to path: String, contentType: String? = nil) async throws -> FirebaseStorage.StorageMetadata {
		let storage = try storage(forPath: path)
		let metadata = StorageMetadata()
		metadata.contentType = contentType
		
		return try await storage.putDataAsync(data, metadata: metadata)
	}
	
	@discardableResult public func moveFile(at src: String, to dst: String, kind: ImageKind?) async throws -> FirebaseStorage.StorageMetadata {
		let srcPath = kind?.path(for: src) ?? src
		let dstPath = kind?.path(for: dst) ?? dst
		let storage = try storage(forPath: srcPath)
		let metadata = try await storage.getMetadata()
		let url = try await storage.downloadURL()
		let local = try await session.download(from: url).0
		let data = try Data(contentsOf: local)
		try? FileManager.default.removeItem(at: local)
		
		let result = try await upload(data: data, to: dstPath, contentType: metadata.contentType)
		try await delete(from: srcPath)
		
		return result
	}
	
	public func data(at path: String) async throws -> Data {
		let url = try await urlForFile(at: path)
		let local = try await session.download(from: url).0
		let data = try Data(contentsOf: local)
		try? FileManager.default.removeItem(at: local)
		return data
	}
	
	public func urlForFile(at path: String) async throws -> URL {
		let storage = try storage(forPath: path)
		
		return try await storage.downloadURL()
	}
	
	public func urlForImage(at path: String, kind: ImageKind = .userSubmitted) async throws -> URL {
		let storage = try storage(forPath: kind.path(for: path))
		
		let url = try await storage.downloadURL()
		return url
	}
	
	func storage(forPath path: String) throws -> StorageReference {
		let components = path.components(separatedBy: "/")
		guard let filename = components.last, components.count > 1 else { throw StorageError.rootStorageNotAllowed }
		
		let storage = Storage.storage().reference(withPath: components.dropLast().joined(separator: "/")).child(filename)
		return storage
	}
	
	public func delete(imagePath: String, kind: ImageKind = .userSubmitted) async throws {
		try await delete(from: kind.path(for: imagePath))
	}
	
	public func delete(from path: String) async throws {
		let storage = try storage(forPath: path)
		try await storage.delete()
	}
}
