//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Peter Khotpanya on 11/8/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//

import UIKit

class FlickrClient {
    
    static let shared = FlickrClient()

    struct Constant {
        //Set up a Flickr developer account at https://www.flickr.com/services/api/
        static let apiKey = MyFlickrDeveloperAccount.apiKey //Your Flickr key
        static let apiSecret = MyFlickrDeveloperAccount.apiSecret //Your Flickr secret
        
        static let apiURL = "https://api.flickr.com/services/rest/"
        static let photoSearchMethod = "flickr.photos.search"
    }
    
    enum SearchResultKey: String{
        case page
        case pages
        case perpage
        case total
        case photo
    }
    
    enum PhotoElement: String{
        case id
        case server
        case farm
        case secret
    }
    
    func getPhotos(lat:Double, lon:Double, perPage: Int, page: Int, completion: @escaping (_ results: [Dictionary<String, Any>], _ errorMessage: String) -> Void){
        let url = String(format: "%@?method=%@&api_key=%@&lat=%@&lon=%@&per_page=%@&page=%@&format=json&nojsoncallback=1", Constant.apiURL , Constant.photoSearchMethod, Constant.apiKey, String(lat), String(lon), String(perPage), String(page))
        let request = URLRequest(url: NSURL(string: url)! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completion([], error?.localizedDescription ?? "")
                return
            }
            
            do{
                let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                let photosDictionary = jsonDictionary["photos"]
                let photoArray = photosDictionary?[SearchResultKey.photo.rawValue]
  
                completion(photoArray as! [Dictionary<String, Any>], "")
            } catch {
                
            }
            
        }
        task.resume()
    }
    
    func getPhotoImage(id: String, server: String, farm: NSNumber, secret: String) -> UIImage{
        let url = URL(string: String(format: "https://farm%@.staticflickr.com/%@/%@_%@_t.jpg", String(describing: farm), server, id, secret))
        let data = try? Data(contentsOf:url!)
        return UIImage(data: data!)!
    }

}
