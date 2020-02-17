

import Foundation
import Alamofire
import SwiftyJSON

protocol RecipeAPIProtocol {
    func getRecipes(recipeName: String, lastResultIndex: Int ,completion:@escaping (_ response: Result<Bool> , _ recipes: [RecipeModel]?, _ lastPage: Int,_ countOfResults: Int)->Void)
    func stopAllSessions()
}

class RecipeAPI: RecipeAPIProtocol{
   
    func getRecipes(recipeName: String, lastResultIndex: Int = 0, completion:@escaping (_ response: Result<Bool> , _ recipes: [RecipeModel]?, _ lastPage: Int, _ countOfResults: Int)->Void) {
         var countOfResults = 0
        guard let url =  URL(string: APIServiceUrl.main+endPoint.search.rawValue+"?") else {
            completion(.failure(APIServiceError.invalidURL),nil,lastResultIndex,countOfResults)
            return}
        let parameters: [String : Any] = ["q": recipeName , "app_id": keys.app_id.rawValue , "app_key": keys.app_key.rawValue  , "to": lastResultIndex]
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .responseJSON { response in
                print(url)
                switch response.result {
                case .failure(let error):
                    completion(.failure(error),nil,lastResultIndex,countOfResults)
                case .success(let success):
                    let json = JSON(success)
                    let statusCode = response.response?.statusCode
                    switch statusCode {
                    case 200:
                        do {
                            let jsonData = try json["hits"].rawData()
                            print(jsonData)
                            let recipes = try JSONDecoder()
                                .decode([FailableDecodable<RecipeModel>].self,from: jsonData)
                                .compactMap { $0.base }
                            countOfResults = json["count"].int!
                            completion(.success(true),recipes,lastResultIndex,countOfResults)
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    default:
                        completion(.success(false),nil,lastResultIndex,countOfResults)
                    }
                }
        }
    }
    func stopAllSessions() {
       let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
        dataTasks.forEach { $0.cancel() }
        uploadTasks.forEach { $0.cancel() }
        downloadTasks.forEach { $0.cancel() }
        }
    }
}


