import UIKit

struct Lugar: Codable {
    var titulo: String
    var longitud: Double
    var latitud: Double
}

struct Lugares: Codable{
    var lugares: [Lugar]
}

func cargaJSON(archivo: String) -> Lugares?{
    guard let url = Bundle.main.url(forResource: archivo, withExtension: "json") else{ return nil}
    do {
        return try JSONDecoder().decode(Lugares.self, from: Data(contentsOf: url))
    } catch { return nil}
}
