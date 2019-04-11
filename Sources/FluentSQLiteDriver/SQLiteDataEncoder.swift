import Foundation

public struct SQLiteDataEncoder {
    public init() { }

    public func encode(_ type: Encodable) throws -> SQLiteData {
        if let custom = type as? SQLiteDataConvertible {
            return custom.sqliteData ?? .null
        } else {
            do {
                let encoder = _Encoder()
                try type.encode(to: encoder)
                return encoder.data
            } catch is DoJSON {
                let json = JSONEncoder()
                let data = try json.encode(Wrapper(type))
                var buffer = ByteBufferAllocator().buffer(capacity: data.count)
                #warning("TODO: use nio foundation compat write")
                buffer.writeBytes(data)
                return SQLiteData.blob(buffer)
            }
        }
    }

    private final class _Encoder: Encoder {
        var codingPath: [CodingKey] {
            return []
        }

        var userInfo: [CodingUserInfoKey : Any] {
            return [:]
        }
        var data: SQLiteData
        init() {
            self.data = .null
        }

        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            return .init(_KeyedValueEncoder(self))
        }

        func unkeyedContainer() -> UnkeyedEncodingContainer {
            fatalError()
        }

        func singleValueContainer() -> SingleValueEncodingContainer {
            return _SingleValueEncoder(self)
        }
    }

    #warning("TODO: fix fatal errors")

    struct DoJSON: Error {}

    #warning("TODO: move to encodable kit")
    struct Wrapper: Encodable {
        let encodable: Encodable
        init(_ encodable: Encodable) {
            self.encodable = encodable
        }
        func encode(to encoder: Encoder) throws {
            try self.encodable.encode(to: encoder)
        }
    }

    private struct _KeyedValueEncoder<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {
        var codingPath: [CodingKey] {
            return self.encoder.codingPath
        }

        let encoder: _Encoder
        init(_ encoder: _Encoder) {
            self.encoder = encoder
        }

        mutating func encodeNil(forKey key: Key) throws {
            fatalError()
        }

        mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            throw DoJSON()
        }

        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            fatalError()
        }

        mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            fatalError()
        }

        mutating func superEncoder() -> Encoder {
            fatalError()
        }

        mutating func superEncoder(forKey key: Key) -> Encoder {
            fatalError()
        }
    }


    private struct _SingleValueEncoder: SingleValueEncodingContainer {
        var codingPath: [CodingKey] {
            return self.encoder.codingPath
        }

        let encoder: _Encoder
        init(_ encoder: _Encoder) {
            self.encoder = encoder
        }

        mutating func encodeNil() throws {
            // data already null
        }

        mutating func encode(_ value: Bool) throws {
            switch value {
            case true:
                self.encoder.data = SQLiteData.integer(1)
            case false:
                self.encoder.data = SQLiteData.integer(0)
            }
        }

        mutating func encode(_ value: String) throws {
            self.encoder.data = SQLiteData.text(value)
        }

        mutating func encode(_ value: Double) throws {
            self.encoder.data = SQLiteData.float(value)
        }

        mutating func encode(_ value: Float) throws {
            self.encoder.data = SQLiteData.float(.init(value))
        }

        mutating func encode(_ value: Int) throws {
            self.encoder.data = SQLiteData.integer(value)
        }

        mutating func encode(_ value: Int8) throws {
            fatalError()
        }

        mutating func encode(_ value: Int16) throws {
            fatalError()
        }

        mutating func encode(_ value: Int32) throws {
            fatalError()
        }

        mutating func encode(_ value: Int64) throws {
            fatalError()
            // self.encoder.data = SQLiteData(int64: value)
        }

        mutating func encode(_ value: UInt) throws {
            fatalError()
        }

        mutating func encode(_ value: UInt8) throws {
            fatalError()
        }

        mutating func encode(_ value: UInt16) throws {
            fatalError()
        }

        mutating func encode(_ value: UInt32) throws {
            fatalError()
        }

        mutating func encode(_ value: UInt64) throws {
            fatalError()
        }

        mutating func encode<T>(_ value: T) throws where T : Encodable {
            try value.encode(to: self.encoder)
        }
    }
}
