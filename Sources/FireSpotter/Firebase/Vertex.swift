//
//  Vertex.swift
//  FireSpotter
//
//  Created by Ben Gottlieb on 3/2/25.
//

import Suite
import FirebaseVertexAI

public actor Vertex {
	public static let instance = Vertex()
	
	
	let vertex = VertexAI.vertexAI()
	
	public struct SanitizeResponse: Codable, Sendable {
		public let payload: Payload
		public struct Payload: Codable, Sendable {
			public let is_appropriate: Bool
			public let sanitized: String
		}
	}

	let jsonSchema = Schema.object(
		 properties: [
			 "sanitized": .string(description: "sanitized text"),
			  "is_appropriate": .boolean(description: "is this appropriate?")
		 ]
	)
	
	enum VertexError: Error { case noDataReturned }

	public func run(prompt: String) async throws -> String {
		let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
		let response = try await model.generateContent([prompt])
		
		return response.text ?? ""

	}
	
	public func sanitize(text: String) async throws -> SanitizeResponse {
		let config = GenerationConfig(
			 responseMIMEType: "application/json",
			 responseSchema: jsonSchema
		)
		
		let spouseLabel = "husband"
		let relationshipStatus = "strained"
		let temp = "cool"
		
		let prompt = """
				I'm writing a message to my \(spouseLabel). Our relationship is currently \(relationshipStatus). Can you please tell me if it's appropriate to send to a spouse, and make sure it's not too harsh, but it should have a \(temp) tone: \(text)
		"""
		let model = vertex.generativeModel(modelName: "gemini-1.5-flash", generationConfig: config)
		let response = try await model.generateContent([prompt])

		guard let data = response.text?.data(using: .utf8) else { throw VertexError.noDataReturned }
		
		let payload = try JSONDecoder().decode(SanitizeResponse.Payload.self, from: data)
		
		return SanitizeResponse(payload: payload)
	}
}
