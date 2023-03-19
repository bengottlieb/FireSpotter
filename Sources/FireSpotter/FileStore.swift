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

public class FileStore {
	public static let instance = FileStore()
	
	public var maxUploadedImageSize = CGSize(width: 500, height: 500)
	
	enum StorageError: Error { case rootStorageNotAllowed, noImageData, failedToResizeImage }
	
	@discardableResult public func upload(image: UXImage, to path: String, quality: Double = 0.9) async throws -> FirebaseStorage.StorageMetadata {
		var uploadedImage = image
		if image.size.width > maxUploadedImageSize.width || image.size.width > maxUploadedImageSize.width {
			guard let resized = image.resized(to: maxUploadedImageSize, trimmed: true) else { throw StorageError.failedToResizeImage }
			uploadedImage = resized
		}
		
		guard let data = quality == 1.0 ? uploadedImage.pngData() : uploadedImage.jpegData(compressionQuality: quality) else { throw StorageError.noImageData }
		let contentType = quality == 1.0 ? "image/png" : "image/jpeg"
		
		return try await upload(data: data, to: path, contentType: contentType)
	}
	
	@discardableResult public func upload(data: Data, to path: String, contentType: String? = nil) async throws -> FirebaseStorage.StorageMetadata {
		let storage = try storage(forPath: path)
		let metadata = StorageMetadata()
		metadata.contentType = contentType
		
		return try await storage.putDataAsync(data, metadata: metadata)
	}
	
	public func urlForFile(at path: String) async throws -> URL {
		let storage = try storage(forPath: path)
		
		return try await storage.downloadURL()
	}
	
	func storage(forPath path: String) throws -> StorageReference {
		let components = path.components(separatedBy: "/")
		guard let filename = components.last, components.count > 1 else { throw StorageError.rootStorageNotAllowed }
		
		let storage = Storage.storage().reference(withPath: components.dropLast().joined(separator: "/")).child(filename)
		return storage
	}
}
