//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//
import Foundation

class TMDBClient {
    
    static let apiKey = "YOUR_API"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        case getWatchlist
        case getRequestToken
        case login
        case createSessionId
        case logout
        case getFavoritesList
        case search(String)
        case addToWatchList
        case addToFavorites
        case getImage(String)
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base+"/account/\(Auth.accountId)/watchlist/movies"+Endpoints.apiKeyParam+"&session_id=\(Auth.sessionId)"
            case .getRequestToken:
                return Endpoints.base+"/authentication/token/new"+Endpoints.apiKeyParam
            case .login:
                return Endpoints.base+"/authentication/token/validate_with_login"+Endpoints.apiKeyParam
            case .createSessionId:
                return Endpoints.base+"/authentication/session/new"+Endpoints.apiKeyParam
            case .logout:
                return Endpoints.base+"/authentication/session"+Endpoints.apiKeyParam
            case .getFavoritesList:
                return Endpoints.base+"/account/\(Auth.accountId)/favorite/movies"+Endpoints.apiKeyParam+"&session_id=\(Auth.sessionId)"
            case .search(let query):
                return Endpoints.base+"/search/movie"+Endpoints.apiKeyParam+"&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            case .addToWatchList:
                return Endpoints.base+"/account/\(Auth.accountId)/watchlist"+Endpoints.apiKeyParam+"&session_id=\(Auth.sessionId)"
            case .addToFavorites:
                return Endpoints.base+"/account/\(Auth.accountId)/favorite"+Endpoints.apiKeyParam+"&session_id=\(Auth.sessionId)"
            case .getImage(let posterPath):
                return "https://image.tmdb.org/t/p/w500/"+posterPath
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGetRequest <ReponseType: Decodable> (url: URL , responseType: ReponseType.Type , completion: @escaping(ReponseType? , Error?) -> Void) -> URLSessionTask {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let safeData = data {
                let decoder = JSONDecoder()
                do {
                    let responseObjects = try decoder.decode(ReponseType.self, from: safeData)
                    DispatchQueue.main.async {
                        completion(responseObjects, nil)
                    }
                } catch {
                    do {
                        let errorResponse = try decoder.decode(TMDBResponse.self, from: safeData) as Error
                        DispatchQueue.main.async {
                            completion (nil , errorResponse)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void){
        let url = Endpoints.getRequestToken.url
        taskForGetRequest(url: url, responseType: RequestTokenResponse.self) { response, error in
            if let safeResponse = response {
                Auth.requestToken = safeResponse.requestToken
                    completion(true , nil)
            }else {
                    completion(false , error)
            }
        }
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        let url = Endpoints.getWatchlist.url
        let session = URLSession(configuration: .default)
        taskForGetRequest(url: url, responseType: MovieResults.self) { response, error in
            if let safeResponse = response {
                completion(safeResponse.results, nil)
            }else{
                completion([], error)
            }
        }
    }
    
    class func getFavoritesList (completion: @escaping([Movie] , Error?) -> Void){
        let url = Endpoints.getFavoritesList.url
        let session = URLSession(configuration: .default)
        taskForGetRequest(url: url, responseType: MovieResults.self) { response, error in
            if let safeResponse = response {
                completion(safeResponse.results , nil)
            }else{
                completion([] , error)
            }
        }
    }
    
    class func search (query: String , completion: @escaping([Movie] , Error?) -> Void) -> URLSessionTask{
        let url = Endpoints.search(query).url
        let session = URLSession(configuration: .default)
        let task = taskForGetRequest(url: url, responseType: MovieResults.self) { response, error in
            if let safeResponse = response {
                completion(safeResponse.results,nil)
            }else {
                completion([],error)
            }
        }
        return task
    }
    
    class func taskForPostRequest <RequestType: Encodable , ResponseType: Decodable> (request: URL , body: RequestType , responseType: ResponseType.Type , completion: @escaping(ResponseType? , Error?) -> Void ) {
        var request = URLRequest(url: request)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            if let safeData = data {
                let decode = JSONDecoder()
                do {
                    let responseObjects = try decode.decode(ResponseType.self, from: safeData)
                    DispatchQueue.main.async {
                        completion(responseObjects , nil)
                    }
                } catch  {
                    do {
                        let errorResponse = try decode.decode(TMDBResponse.self, from: safeData) as Error
                        DispatchQueue.main.async {
                            completion(nil, errorResponse)
                        }
                    } catch  {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
            }
        }
        task.resume()
    }
            
    class func login(username: String , password: String , completion: @escaping(Bool , Error?) -> Void){
        let body = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)
        taskForPostRequest(request: Endpoints.login.url , body: body, responseType: RequestTokenResponse.self) { response, error in
            if let safeResponse = response {
                Auth.requestToken = safeResponse.requestToken
                completion(true,nil)
            }else {
                completion(false,error)
            }
        }
    }
    
    class func createSessionId(completion: @escaping(Bool , Error?) -> Void){
        let body = PostSession(requestToken: Auth.requestToken)
        taskForPostRequest(request: Endpoints.createSessionId.url, body: body, responseType: SessionResponse.self) { response, error in
            if let safeResponse = response {
                Auth.sessionId = safeResponse.sessionId
                completion(true,nil)
            }else{
                completion (false,error)
            }
        }
    }
    
    class func endSession (completion: @escaping(Bool , Error?) -> Void){
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = Logout(session: Auth.sessionId)
        request.httpBody = try! JSONEncoder().encode(body)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, Error in
            if let safeData = data{
                Auth.requestToken = ""
                Auth.sessionId = ""
                completion(true,nil)
            }
        }
        task.resume()
    }
    
    class func addToWatchList(movieId:Int, watchlist:Bool , completion: @escaping(Bool , Error?) -> Void){
        let body = MarkWatchlist(mediaType: "movie", mediaId: movieId, watchlist: watchlist)
        taskForPostRequest(request: Endpoints.addToWatchList.url, body: body, responseType: TMDBResponse.self) { response, error in
            if let safeResponse = response {
                completion(safeResponse.statusCode == 1 || safeResponse.statusCode == 12 || safeResponse.statusCode == 13 , nil)
            }else{
                completion(false,error)
            }
        }
    }
    
    class func addToFavorites (mediaId: Int , favorite: Bool , completion: @escaping(Bool , Error?) -> Void){
        let body = MarkFavorite(mediaType: "movie", mediaId: mediaId, favorite: favorite)
        taskForPostRequest(request: Endpoints.addToFavorites.url, body: body, responseType: TMDBResponse.self) { response, error in
            if let safeResponse = response {
                completion(safeResponse.statusCode == 1 || safeResponse.statusCode == 12 || safeResponse.statusCode == 13 , nil)
            }else{
                completion(false,error)
            }
        }
    }
    
    class func getImage (posterPath: String , completion: @escaping(Data? , Error?) -> Void){
        let url = Endpoints.getImage(posterPath).url
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                completion(data , error)
            }
        }
        task.resume()
    }
}
