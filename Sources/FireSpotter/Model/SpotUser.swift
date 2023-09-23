//
//  SpotUserRecord.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import Foundation
import CrossPlatformKit

public protocol SpotUser: SpotRecord {
	var firstName: String? { get }
	var lastName: String? { get }
	var emailAddress: String? { get }
	var profileImageURL: URL?  { get async throws }
	var apnsTokens: [APNSDeviceInfo]? { get }
}

//public typealias SpotUserDocument = SpotDocument<SpotUser>

public struct SpotUserRecord: SpotUser {
	public var id = String.id(for: SpotUserRecord.self)
	public var firstName: String?
	public var lastName: String?
	public var emailAddress: String?

	public var profileImageURL: URL? {
		get async throws {
			return try await FileStore.instance.urlForImage(at: id, kind: .avatar)
		}
	}
	
	public var apnsTokens: [APNSDeviceInfo]?
		
	public static var minimalRecord = SpotUserRecord(id: "")
	public func awakeFromFetch(in document: SpotDocument<Self>) async { }

	@MainActor public static func newRecord(withID id: String) -> Self {
		SpotUserRecord(id: id)
	}
}

extension SpotDocument where Record == SpotUserRecord {
	
	public func setProfileImage(_ image: UXImage) async throws {
		try await FileStore.instance.upload(image: image, kind: .avatar, to: id)
		self.save()
	}
}
