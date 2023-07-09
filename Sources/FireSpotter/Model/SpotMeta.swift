//
//  SpotMeta.swift
//  
//
//  Created by Ben Gottlieb on 3/5/23.
//

import Suite

public struct SpotMeta: SpotRecord {
	public var id: String
	var minimalData: String?
	var testDate: Date?
	
	var minimalJSON: [String: Any]? {
		get {
			guard let string = minimalData, let data = Data(base64Encoded: string) else { return nil }
			return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
		}
		
		set {
			guard let newValue else { return }
			minimalData = try? JSONSerialization.data(withJSONObject: newValue).base64EncodedString()
		}
	}
	
	public static var minimalRecord = SpotMeta(id: "")
	public func awakeFromFetch(in document: SpotDocument<Self>) async {
		document.record.testDate = Date().byAdding(days: 10)
		document.save()
	}
	@MainActor public static func newRecord(withID id: String) -> Self { fatalError("SpotMeta.newRecord() should never be called") }
}

extension SpotMeta: DateKeyProvider {
	static public func isDateKey(_ key: String) -> Bool {
		return key == "testDate"
	}
}

extension SpotDocument where Record == SpotMeta {
	func modelDifferences(json: [String: Any]) async -> KeyDifferences? {
		guard let current = record.minimalJSON else {
			record.minimalJSON = json
			save()
			return nil
		}
		
		let diff = json.diff(relativeTo: current)
		var isMateriallyChanged = !diff.additions.isEmpty || !diff.changes.isEmpty
		if isMateriallyChanged, (try? await collection!.isEmpty) == true { isMateriallyChanged = false }
		if !isMateriallyChanged {
			if !diff.isEmpty {
				record.minimalJSON = json
				save()
			}
			return nil
		}
		
		return diff
	}
	

}
