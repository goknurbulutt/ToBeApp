//
//  ViewController.swift
//  ToBe
//
//  Created by Göknur Bulut on 19.07.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var notTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    //bir konum yöneticisi tanımlayıp import ettiğimiz coreLocationun bir sınıfı olan CLLOcationManageri kullandık,konumla ilgili tüm özellikleri yonetmemizi sağlayacak bir obje
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    
    var chosenName = ""
    var chosenİd : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager.delegate = self
        //locationManagerin de delegasyonunu view controllera veriyoruz.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        konum keskinliği
        locationManager.requestWhenInUseAuthorization()
//        uygulama kullanılırken konum almaya izin verilsin
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer: )))
//        kullanıcının haritayaa uzun basmasıyla birlikte işaret pini oluşturmak için kullanılır.
        gestureRecognizer.minimumPressDuration = 3
//        kullanıcı kaç saniye bastığında algılansın
        mapView.addGestureRecognizer(gestureRecognizer)
        
        
        if chosenName != "" {
//            core datadan verileri çek
            
            if let uuidString = chosenİd?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0 {
                        
                        for result in results as! [NSManagedObject]{
                            
                            if let name = result.value(forKey: "name") as? String{
                                
                                annotationTitle = name
                               
                                if let not = result.value(forKey: "note") as? String{
                                    annotationSubtitle = not
                                    
                                    if let latitude = result.value(forKey: "latitude") as? Double{
                                        annotationLatitude = latitude
                                     
                                        if let longitude = result.value(forKey: "longitude") as? Double{
                                            annotationLongitude = longitude
                   
                            
                            let annotation = MKPointAnnotation()
                            annotation.title = annotationTitle
                            annotation.subtitle = annotationSubtitle
                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                            annotation.coordinate = coordinate
                            
                            mapView.addAnnotation(annotation)
                            isimTextField.text = annotationTitle
                            notTextField.text = annotationSubtitle
                            
                            locationManager.stopUpdatingLocation()
                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            let region = MKCoordinateRegion(center: coordinate, span: span)
                            mapView.setRegion(region, animated: true)
                            
                                            
                                        
                                }
                                
                            }
                                
                        }
                                
                    }
                            
                }
            }
                    
                } catch {
                    print("hata var")
                }
                
            }
            
        } else {
            
//            yeni veri eklemeye geldi
        }
        
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
            
        }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .green

            
            
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        }else{
            pinView?.annotation = annotation
            
        }
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if chosenName != "" {
            
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarkSeries, hata) in
                
                if let placemarks = placemarkSeries{
                    if placemarks.count > 0 {
                        
                        
                        let newPlacemark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.annotationTitle
//                       asıl amaç olan navigasyonu açmak
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        
                        
                        item.openInMaps(launchOptions: launchOptions)
                        
                    }
                }
                
                
            }
            
        }
    }
    
    
    
    
    @objc func chooseLocation (gestureRecognizer : UILongPressGestureRecognizer ) {
        
        if gestureRecognizer.state == .began {
            
            let touchPoint = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
//            dokunulan noktayı kordinata çevirme
            
            
            chosenLatitude = touchCoordinate.latitude
            chosenLongitude = touchCoordinate.longitude
//            kullanıcı tıkladığı gibi tıkladığı yerden enlem ve boylamı alabilmek için
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
//            dokunulan kordinata işaretleme verme
            annotation.title = isimTextField.text
//            başlık veriyoruz
            annotation.subtitle = notTextField.text
//            alt yazı veriyoruz.
            mapView.addAnnotation(annotation)
//            annotationun eklenmesi
        }
//            jest algılayıcının durumunu ölçmek için ve o sırada nelerin yapılacağını söylemek için.
        
       
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations[0].coordinate.latitude)
//        print(locations[0].coordinate.longitude) bunlar kullanıcının konumunu almak için yazıldı.
        if chosenName == ""{
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
//        aldığımız enklemm ve boylamdan bir locatipn oluşturuyoruz
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        }
        
    }

    @IBAction func saveClicked(_ sender: Any) {
        
//        contexte ulaşmak istiyoruz model belli içerisine ns entiti discripşınla birlikte insert into yapıcaz sonra save edicez contexti kullanarak
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
//        bundan sonra context .save demeye hazırız ama ayarları yapmak lazım.
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Place", into: context)
        
        newPlace.setValue(isimTextField.text, forKey: "name")
        newPlace.setValue(notTextField.text, forKey: "note")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("kayıt edildi")
        } catch{
            print("Hata")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlaceCreated"), object: nil)
        navigationController?.popViewController(animated: true)
        
        
        
    }
    
}

