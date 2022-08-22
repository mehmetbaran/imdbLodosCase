//
//  ViewController.swift
//  Lodos
//
//  Created by mac on 22.08.2022.
//  Copyright © 2022 mac. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table: UITableView!
    @IBOutlet var field: UITextField!
    var movies = [Movie] ()

    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(MovieTableViewCell.nib(), forCellReuseIdentifier: MovieTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        field.delegate = self
        self.table.layer.cornerRadius = 10
        self.table.layer.borderWidth = 1;
        self.field.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if CheckInternet.Connection(){
            
          //  self.AlertSuccess(Message: "Başarılı bir şekilde bağlantı kurdunuz. Hemen film arayabilirsiniz!")
        }
        else {
            
            self.Alert(Message: "Cihazınız internete bağlı değil. Bağlantınızı kontrol edip tekrar deneyiniz!")
        }
    }
    
    func Alert (Message: String){
        let alert = UIAlertController(title: "Dikkat", message: Message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func AlertSuccess (Message: String){
        let alert = UIAlertController(title: "", message: Message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "TAMAM", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
// Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchMovies()
        return true
    }
    
    func searchMovies() {
        field.resignFirstResponder()
        guard let text = field.text, !text.isEmpty else {
          return
      }
        
        let query = text.replacingOccurrences(of: "", with: "%20")
        movies.removeAll()
        URLSession.shared.dataTask(with: URL(string: "https://www.omdbapi.com/?apikey=b99744fa&s=\(query)&type=movie")!,      completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            // Convert
            var result: MovieResult?
            do {
                result  = try JSONDecoder().decode(MovieResult.self, from: data)
            } catch {
                print("error")
            }
            guard let finalResult = result else {
                return
            }
            // print("\(finalResult.Search.first?.Title)")
            
            // update
            let newMovies = finalResult.Search
            self.movies.append(contentsOf: newMovies)
            
            // refresh
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }).resume()
    }
    
// table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as! MovieTableViewCell
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // show movie details
        let url = "https://www.imdb.com/title/\(movies[indexPath.row].imdbID)"
        let vc = SFSafariViewController(url: URL(string: url)!)
        present(vc, animated:  true)
    }
}
struct MovieResult: Codable {
    
    let Search: [Movie]
}
struct Movie: Codable {
    let Title: String
    let Year: String
    let imdbID: String
    let _Type: String
    let Poster: String
    
    private enum CodingKeys: String, CodingKey {
        case Title, Year, imdbID, _Type = "Type", Poster
    }
}

