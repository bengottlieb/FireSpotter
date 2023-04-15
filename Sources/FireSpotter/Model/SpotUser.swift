//
//  SpotUser.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Foundation
import CrossPlatformKit

public typealias SpotUserDocument = SpotDocument<SpotUser>

public struct SpotUser: SpotRecord {
	public var id = String.id(for: SpotUser.self)
	public var firstName: String?
	public var lastName: String?
	public var emailAddress: String?

	public var profileImageURL: URL? {
		get async throws {
			return try await FileStore.instance.urlForImage(at: id, kind: .avatar)
		}
	}
	
	var apnsTokens: [APNSDeviceInfo]?
		
	public static var minimalRecord = SpotUser(id: "")
	public static var emptyUser = SpotDocument(SpotUser(id: ""), collection: FirestoreManager.instance.users)
	
	@MainActor public static func newRecord(withID id: String) -> Self {
		SpotUser(id: id)
	}
}

extension SpotDocument where Record == SpotUser {
	
	public func setProfileImage(_ image: UXImage) async throws {
		try await FileStore.instance.upload(image: image, kind: .avatar, to: id)
		self.save()
	}
}
