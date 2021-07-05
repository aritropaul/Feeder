//
//  GithubKit.swift
//  Feeder
//
//  Created by Aritro Paul on 6/20/21.
//

import Foundation

enum RequestType: String {
    case get
    case post
    case put
    case delete
}

protocol GHDelegate: AnyObject {
    func didFailWith(error: Error)
}

protocol UserDelegate: GHDelegate {
    func DidGetUser(user: User)
}

protocol EventsDelegate: GHDelegate {
    func didGetEvents(events: [Event])
}

protocol RepoDelegate: GHDelegate {
    func didGetRepo(repo: Repository)
}

class API {
    static let shared = API()
    static var clientID = ""
    static var clientSecret = ""
    static let callback = "feeder://login/".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    static var token = ""
    
    weak var userDelegate: UserDelegate?
    weak var eventsDelegate: EventsDelegate?
    weak var repoDelegate: RepoDelegate?
    
    func loadKeys() {
        if let path = Bundle.main.path(forResource: "keys", ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  if let jsonResult = jsonResult as? Dictionary<String, String> {
                      API.clientID = jsonResult["clientID"] ?? ""
                      API.clientSecret = jsonResult["clientSecret"] ?? ""
                  }
              } catch {
                   print("🥵 Could not load keys")
              }
        }
    }
    
    
    private func request<T:Codable>(type: RequestType, base: String, endpoint: String, headers: [String: String]? = nil, completion: @escaping(Result<T, Error>)->()) {
        let url = URL(string: base + endpoint)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        if headers != nil {
            guard let headers = headers else { return }
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            print("🔌 URL: \(url)")
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
                print("✅ Decode Success")
            }
            catch (let error) {
                completion(.failure(error))
                print("⬇️ Data: \(String(data:data, encoding: .utf8)!)")
                print("❌ Decode Failed")
            }
        }
        task.resume()
    }
    
    func authenticate(code: String, completion: @escaping(Bool)->()) {
        let base = "https://github.com/login/oauth"
        let endpoint = "/access_token?client_id=\(API.clientID)&redirect_uri=\(API.callback)&client_secret=\(API.clientSecret)&code=\(code)"
        let url = URL(string: base + endpoint)!
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            let str = String(data:data, encoding: .utf8)
            if (str?.contains("error") == true) {
                print(str)
                completion(false)
            }
            else {
                print(String(data:data, encoding: .utf8))
                let accessToken = String(data:data, encoding: .utf8)?.split(separator: "=")[1].split(separator: "&")[0] ?? ""
                API.token = String(accessToken)
                completion(true)
            }
        }
        task.resume()
    }
    
    
    func getUser() {
        let base = "https://api.github.com"
        let endpoint = "/user"
        let headers = ["Authorization": "token \(API.token)"]
        request(type: .get, base: base, endpoint: endpoint, headers: headers) { (result: Result<User, Error>) in
            switch result {
            case .success(let user): self.userDelegate?.DidGetUser(user: user)
            case .failure(let error): self.userDelegate?.didFailWith(error: error)
            }
        }
    }
    
    
    func getEvents(user: User) {
        let base = "https://api.github.com"
        let endpoint = "/users/\(user.login)/received_events?per_page=60"
        let headers = ["Authorization": "token \(API.token)", "Accept": "application/vnd.github.v3+json"]
        request(type: .get, base: base, endpoint: endpoint, headers: headers) { (result: Result<[Event], Error>) in
            switch result {
            case .success(let events): self.eventsDelegate?.didGetEvents(events: events)
            case .failure(let error): self.eventsDelegate?.didFailWith(error: error)
            }
        }
    }
    
    func getRepository(name: String, completion: @escaping(Result<Repository, Error>)->()) {
        let base = "https://api.github.com/repos/"
        let endpoint = name
        let headers = ["Authorization": "token \(API.token)", "Accept": "application/vnd.github.v3+json"]
        request(type: .get, base: base, endpoint: endpoint, headers: headers) { (result: Result<Repository, Error>) in
            completion(result)
        }
    }
    
    func star(type: RequestType, repo: Repo, completion: @escaping(Bool)->()) {
        let base = "https://api.github.com"
        let endpoint = "/user/starred/\(repo.name)"
        let headers = ["Authorization": "token \(API.token)", "Accept": "application/vnd.github.v3+json", "Content-Length": "0"]
        let url = URL(string: base + endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 204 {
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        }
        task.resume()
    }
    
    func getColors() {
        let base = "https://raw.githubusercontent.com"
        let endpoint = "/ozh/github-colors/master/colors.json"
        request(type: .get, base: base, endpoint: endpoint) { (result: Result<Color, Error>) in
            switch result {
            case .success(let clrs): colors = clrs
            case .failure(let error): print(error)
            }
        }
    }
    
}
