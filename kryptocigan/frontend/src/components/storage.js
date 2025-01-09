export function getDataFromStorage(key){
    const dataString = localStorage.getItem(key)
    if(!dataString){
        return null
    }
    const data = JSON.parse(dataString)
}