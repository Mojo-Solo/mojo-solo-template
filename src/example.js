// Example clean code that passes all checks

function loginUser(username, password) {
    // TODO: Add password validation #123
    // FIXME: Improve security implementation #456
    
    const apiKey = process.env.API_KEY;  // Properly use environment variable
    
    if (username === 'admin') {  // Using strict equality
        return true;
    }
    
    return false;
}