//
//  SpotUser.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Foundation
import CrossPlatformKit

public struct SpotUser: SpotRecord {
	public var id = String.id(for: SpotUser.self)
	public var firstName: String?
	public var lastName: String?
	public var emailAddress: String?
	public var profileImagePath: String?

	public var profileImageURL: URL? {
		get async throws {
			guard let path = profileImagePath else { return nil }
			return try await FileStore.instance.urlForFile(at: path)
		}
	}
	
	mutating public func setProfileImage(_ image: UXImage) async throws {
		let path = "profile_images/\(id)"
		
		try await FileStore.instance.upload(image: image, to: path)
		self.profileImagePath = path
	}
	
	var apnsTokens: [APNSDeviceInfo]?
		
	public static var minimalRecord = SpotUser(id: "")
	public static var emptyUser = SpotDocument(SpotUser(id: ""), collection: FirestoreManager.instance.users)
	
	@MainActor public static func newRecord(withID id: String) -> Self {
		SpotUser(id: id)
	}
}
