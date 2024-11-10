enum WordDirectionDTO : Codable {
    case vertical
    case horizontal
    
    func toModel() -> WordDirection {
        switch self {
        case .vertical:
            return .vertical
        case .horizontal:
            return .horizontal
        }
    }
}
