enum WordDirection : Codable {
    case vertical
    case horizontal
    
    func toDTO() -> WordDirectionDTO {
        switch self {
        case .vertical:
            return .vertical
        case .horizontal:
            return .horizontal
        }
    }
}
