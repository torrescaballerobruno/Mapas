import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate{

    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var inicio: UIPickerView!
    @IBOutlet weak var fin: UIPickerView!

    var parserJson: Lugares!
    var iniciol: Lugar!
    var finl: Lugar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inicio.dataSource = self
        self.inicio.delegate = self
        self.fin.dataSource = self
        self.fin.delegate = self
        mapa.delegate = self
        
//        Create region for zoom in CU
        let center = CLLocationCoordinate2D(latitude: 19.324621, longitude: -99.182536)
        let region = MKCoordinateRegion(center: center , span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03));
        mapa.setRegion(region, animated: true);
        
        parserJson = cargaJSON(archivo: "Ubicaciones")
        iniciol = parserJson.lugares[0]
        finl = parserJson.lugares[0]
        crearPuntos(arr: parserJson.lugares)
    }



    @IBAction func buscar(_ sender: UIButton) {

        let iniPl = crearLugar(lugar: iniciol)
        let finPl = crearLugar(lugar: finl)
        let dirs = crearRuta(i: iniPl, f: finPl)
        
        dirs.calculate { (response, error) in
            guard let directionsResponse = response else { return }
            
            self.mapa.removeOverlays(self.mapa.overlays)
            for route in directionsResponse.routes {
                self.mapa.addOverlay(route.polyline)
                self.mapa.setRegion(MKCoordinateRegion(route.polyline.boundingMapRect), animated: true)
            }
        }
    }

    func crearLugar(lugar: Lugar)->MKPlacemark{
        let l = CLLocationCoordinate2D(latitude: lugar.latitud, longitude: lugar.longitud)
        return MKPlacemark(coordinate: l)
    }

    func crearRuta(i:MKPlacemark,f: MKPlacemark )->MKDirections{
        let ruta = MKDirections.Request()
        ruta.source = MKMapItem(placemark: i)
        ruta.destination = MKMapItem(placemark: f)
        ruta.transportType = .automobile
        return MKDirections(request: ruta)
    }

    func crearPuntos(arr: [Lugar]){
        for l in arr {
            let punto = MKPointAnnotation();
            punto.coordinate = CLLocationCoordinate2D(latitude: l.latitud, longitude: l.longitud)
            punto.title = l.titulo
            mapa.addAnnotation(punto)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "PinAnnotationView")
        
        if pin == nil {
            pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "PinAnnotationView")
            pin?.canShowCallout = true
        } else {
            pin?.annotation = annotation
        }
        pin?.image = UIImage(named: "pin")
        return pin
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let line = MKPolylineRenderer(overlay: overlay)
        line.strokeColor = .black
        line.lineWidth = 4.0
        return line
    }

}
