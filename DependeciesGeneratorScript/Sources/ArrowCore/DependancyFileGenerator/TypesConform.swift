import Foundation

func getTypesConform(to type: String, types: Set<Type>) -> Set<Type> {
    var items = Set<Type>()
    let conforms = types.filter { $0.conforms.contains(type) }
    items.formUnion(conforms)
    
    guard !conforms.isEmpty else { return items }
    
    for conform in conforms {
        items.formUnion(getTypesConform(to: conform.fullyName, types: types))
    }

    return items
}
