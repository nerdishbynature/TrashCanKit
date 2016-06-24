import Foundation

internal func += <KeyType, ValueType> (left: inout Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}
