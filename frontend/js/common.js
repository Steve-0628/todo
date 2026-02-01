export const API_BASE = '/api';

export function renderNavbar() {
    const nav = document.createElement('div');
    nav.className = 'navbar';
    const homeLink = document.createElement('a');
    homeLink.href = '/';
    homeLink.innerText = 'Todo App';
    nav.appendChild(homeLink);

    const newLink = document.createElement('a');
    newLink.href = '/new/';
    newLink.innerText = '+ New Todo';
    nav.appendChild(newLink);

    const tagLink = document.createElement('a');
    tagLink.href = '/tag/';
    tagLink.innerText = '+ Add Tag';
    nav.appendChild(tagLink);
    // Select the first child of body to insert before it, or append if empty
    const body = document.body;
    if (body.firstChild) {
        body.insertBefore(nav, body.firstChild);
    } else {
        body.appendChild(nav);
    }
}

export async function apiCall(url, options = {}) {
    try {
        const response = await fetch(API_BASE + url, options);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        // Handle empty responses (like 204 No Content)
        const text = await response.text();
        return text ? JSON.parse(text) : {};
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
}

export function formatDate(timestamp) {
    if (!timestamp) return '';
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    
    // User requested "YYYY/MM/DD with padding".
    return `${year}/${month}/${day}`;
}
