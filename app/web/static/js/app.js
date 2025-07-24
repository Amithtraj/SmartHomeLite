/**
 * SmartHomeLite - Main JavaScript file
 */

// Initialize the application when the DOM is fully loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

/**
 * Initialize the application
 */
function initializeApp() {
    // Setup notification system
    setupNotifications();
    
    // Setup device controls
    setupDeviceControls();
    
    // Setup auto-refresh for dynamic content
    setupAutoRefresh();
    
    // Setup form validations
    setupFormValidations();
    
    // Setup mobile menu toggle
    setupMobileMenu();
    
    // Setup theme toggle (if implemented)
    setupThemeToggle();
    
    console.log('SmartHomeLite app initialized');
}

/**
 * Setup the notification system
 */
function setupNotifications() {
    // Create a notification container if it doesn't exist
    if (!document.getElementById('notification-container')) {
        const container = document.createElement('div');
        container.id = 'notification-container';
        container.className = 'fixed bottom-4 right-4 z-50';
        document.body.appendChild(container);
    }
    
    // Listen for HTMX events to show notifications
    document.body.addEventListener('htmx:afterRequest', function(event) {
        const xhr = event.detail.xhr;
        
        // Only show notifications for non-GET requests
        if (event.detail.requestConfig.verb !== 'get') {
            try {
                // Try to parse the response as JSON
                const response = JSON.parse(xhr.responseText);
                
                if (xhr.status >= 200 && xhr.status < 300) {
                    // Success notification
                    if (response.message) {
                        showNotification(response.message, 'success');
                    }
                } else {
                    // Error notification
                    if (response.detail || response.message) {
                        showNotification(response.detail || response.message, 'error');
                    }
                }
            } catch (e) {
                // If not JSON or parsing fails, check status code
                if (xhr.status >= 400) {
                    showNotification('An error occurred', 'error');
                } else if (xhr.status >= 200 && xhr.status < 300) {
                    // Only show generic success for non-GET requests
                    showNotification('Operation completed successfully', 'success');
                }
            }
        }
    });
    
    // Also listen for errors
    document.body.addEventListener('htmx:responseError', function(event) {
        showNotification('Error: ' + event.detail.error, 'error');
    });
}

/**
 * Show a notification message
 * @param {string} message - The message to display
 * @param {string} type - The type of notification ('success', 'error', 'info')
 * @param {number} duration - How long to show the notification in ms
 */
function showNotification(message, type = 'info', duration = 3000) {
    const container = document.getElementById('notification-container');
    
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type} mb-2 transform transition-transform duration-300 ease-in-out`;
    
    // Add icon based on type
    let icon = '';
    if (type === 'success') {
        icon = '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg>';
    } else if (type === 'error') {
        icon = '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>';
    } else {
        icon = '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>';
    }
    
    notification.innerHTML = `<div class="flex items-center">${icon}${message}</div>`;
    
    // Add close button
    const closeButton = document.createElement('button');
    closeButton.className = 'ml-4 text-white';
    closeButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>';
    closeButton.addEventListener('click', function() {
        notification.classList.add('transform', 'translate-y-2', 'opacity-0');
        setTimeout(() => {
            container.removeChild(notification);
        }, 300);
    });
    
    notification.appendChild(closeButton);
    
    // Add to container
    container.appendChild(notification);
    
    // Remove after duration
    setTimeout(() => {
        notification.classList.add('transform', 'translate-y-2', 'opacity-0');
        setTimeout(() => {
            if (notification.parentNode === container) {
                container.removeChild(notification);
            }
        }, 300);
    }, duration);
}

/**
 * Setup device control functionality
 */
function setupDeviceControls() {
    // Handle device action buttons
    document.addEventListener('click', function(event) {
        // Check if the clicked element is a device action button
        if (event.target.matches('[data-device-action]') || event.target.closest('[data-device-action]')) {
            const button = event.target.matches('[data-device-action]') ? 
                event.target : event.target.closest('[data-device-action]');
            
            const deviceId = button.getAttribute('data-device-id');
            const action = button.getAttribute('data-device-action');
            
            if (deviceId && action) {
                // Show loading state
                const originalContent = button.innerHTML;
                button.innerHTML = '<svg class="animate-spin h-5 w-5 mx-auto" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>';
                button.disabled = true;
                
                // Send the action request
                fetch(`/api/devices/${deviceId}/actions`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ action: action })
                })
                .then(response => response.json())
                .then(data => {
                    // Restore button state
                    button.innerHTML = originalContent;
                    button.disabled = false;
                    
                    // Show notification
                    if (data.success) {
                        showNotification(`Action '${action}' executed successfully`, 'success');
                        
                        // Update device status if provided
                        if (data.status) {
                            updateDeviceStatus(deviceId, data.status);
                        }
                    } else {
                        showNotification(`Failed to execute action: ${data.error || 'Unknown error'}`, 'error');
                    }
                })
                .catch(error => {
                    // Restore button state
                    button.innerHTML = originalContent;
                    button.disabled = false;
                    
                    // Show error
                    showNotification(`Error: ${error.message}`, 'error');
                });
            }
        }
    });
}

/**
 * Update the displayed status of a device
 * @param {string} deviceId - The ID of the device
 * @param {string} status - The new status
 */
function updateDeviceStatus(deviceId, status) {
    // Find status indicators for this device
    const statusElements = document.querySelectorAll(`[data-device-status="${deviceId}"]`);
    
    statusElements.forEach(element => {
        // Update text content
        element.textContent = status.charAt(0).toUpperCase() + status.slice(1);
        
        // Update classes
        element.classList.remove('bg-green-100', 'text-green-800', 'bg-red-100', 'text-red-800', 'bg-gray-100', 'text-gray-800');
        
        if (status === 'online' || status === 'connected' || status === 'on') {
            element.classList.add('bg-green-100', 'text-green-800');
        } else if (status === 'offline' || status === 'disconnected' || status === 'off') {
            element.classList.add('bg-red-100', 'text-red-800');
        } else {
            element.classList.add('bg-gray-100', 'text-gray-800');
        }
    });
    
    // Also update any status indicators
    const indicators = document.querySelectorAll(`[data-device-indicator="${deviceId}"]`);
    
    indicators.forEach(indicator => {
        indicator.classList.remove('bg-green-600', 'bg-red-600', 'bg-gray-600');
        
        if (status === 'online' || status === 'connected' || status === 'on') {
            indicator.classList.add('bg-green-600');
        } else if (status === 'offline' || status === 'disconnected' || status === 'off') {
            indicator.classList.add('bg-red-600');
        } else {
            indicator.classList.add('bg-gray-600');
        }
    });
}

/**
 * Setup auto-refresh for dynamic content
 */
function setupAutoRefresh() {
    // Auto-refresh device list on dashboard
    const devicesList = document.getElementById('devices-list');
    if (devicesList && devicesList.hasAttribute('data-auto-refresh')) {
        const refreshInterval = parseInt(devicesList.getAttribute('data-refresh-interval')) || 30000;
        
        setInterval(() => {
            // Only refresh if the page is visible
            if (!document.hidden) {
                const refreshUrl = devicesList.getAttribute('data-refresh-url') || '/api/devices';
                
                fetch(refreshUrl)
                    .then(response => response.json())
                    .then(data => {
                        // This assumes the endpoint returns HTML to replace the content
                        // If it returns JSON, you'd need to build the HTML here
                        if (data.html) {
                            devicesList.innerHTML = data.html;
                        }
                    })
                    .catch(error => console.error('Error refreshing devices:', error));
            }
        }, refreshInterval);
    }
    
    // Auto-refresh system info on about page
    const systemInfo = document.getElementById('system-info');
    if (systemInfo && systemInfo.hasAttribute('data-auto-refresh')) {
        const refreshInterval = parseInt(systemInfo.getAttribute('data-refresh-interval')) || 30000;
        
        setInterval(() => {
            // Only refresh if the page is visible
            if (!document.hidden) {
                fetch('/api/system/info')
                    .then(response => response.json())
                    .then(data => {
                        // Update CPU usage
                        const cpuElement = document.querySelector('[data-system-info="cpu_usage"]');
                        if (cpuElement) {
                            cpuElement.textContent = data.cpu_usage + '%';
                            const cpuBar = document.querySelector('[data-system-bar="cpu_usage"]');
                            if (cpuBar) cpuBar.style.width = data.cpu_usage + '%';
                        }
                        
                        // Update Memory usage
                        const memoryElement = document.querySelector('[data-system-info="memory_usage"]');
                        if (memoryElement) {
                            memoryElement.textContent = data.memory_usage + '%';
                            const memoryBar = document.querySelector('[data-system-bar="memory_usage"]');
                            if (memoryBar) memoryBar.style.width = data.memory_usage + '%';
                        }
                        
                        // Update Disk usage
                        const diskElement = document.querySelector('[data-system-info="disk_usage"]');
                        if (diskElement) {
                            diskElement.textContent = data.disk_usage + '%';
                            const diskBar = document.querySelector('[data-system-bar="disk_usage"]');
                            if (diskBar) diskBar.style.width = data.disk_usage + '%';
                        }
                        
                        // Update uptime
                        const uptimeElement = document.querySelector('[data-system-info="uptime"]');
                        if (uptimeElement) {
                            uptimeElement.textContent = data.uptime;
                        }
                    })
                    .catch(error => console.error('Error refreshing system info:', error));
            }
        }, refreshInterval);
    }
}

/**
 * Setup form validations
 */
function setupFormValidations() {
    // Get all forms with data-validate attribute
    const forms = document.querySelectorAll('form[data-validate]');
    
    forms.forEach(form => {
        form.addEventListener('submit', function(event) {
            // Check all required fields
            const requiredFields = form.querySelectorAll('[required]');
            let isValid = true;
            
            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    isValid = false;
                    field.classList.add('border-red-500');
                    
                    // Add error message if it doesn't exist
                    let errorMessage = field.nextElementSibling;
                    if (!errorMessage || !errorMessage.classList.contains('validation-error')) {
                        errorMessage = document.createElement('p');
                        errorMessage.className = 'text-red-500 text-xs mt-1 validation-error';
                        errorMessage.textContent = 'This field is required';
                        field.parentNode.insertBefore(errorMessage, field.nextSibling);
                    }
                } else {
                    field.classList.remove('border-red-500');
                    
                    // Remove error message if it exists
                    const errorMessage = field.nextElementSibling;
                    if (errorMessage && errorMessage.classList.contains('validation-error')) {
                        errorMessage.remove();
                    }
                }
            });
            
            // Validate email fields
            const emailFields = form.querySelectorAll('input[type="email"]');
            emailFields.forEach(field => {
                if (field.value.trim() && !isValidEmail(field.value)) {
                    isValid = false;
                    field.classList.add('border-red-500');
                    
                    // Add error message if it doesn't exist
                    let errorMessage = field.nextElementSibling;
                    if (!errorMessage || !errorMessage.classList.contains('validation-error')) {
                        errorMessage = document.createElement('p');
                        errorMessage.className = 'text-red-500 text-xs mt-1 validation-error';
                        errorMessage.textContent = 'Please enter a valid email address';
                        field.parentNode.insertBefore(errorMessage, field.nextSibling);
                    }
                }
            });
            
            // Prevent form submission if validation fails
            if (!isValid) {
                event.preventDefault();
                event.stopPropagation();
                
                // Show validation error notification
                showNotification('Please fix the validation errors', 'error');
            }
        });
        
        // Clear validation errors when input changes
        form.querySelectorAll('input, select, textarea').forEach(field => {
            field.addEventListener('input', function() {
                field.classList.remove('border-red-500');
                
                // Remove error message if it exists
                const errorMessage = field.nextElementSibling;
                if (errorMessage && errorMessage.classList.contains('validation-error')) {
                    errorMessage.remove();
                }
            });
        });
    });
}

/**
 * Validate email format
 * @param {string} email - The email to validate
 * @returns {boolean} - Whether the email is valid
 */
function isValidEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

/**
 * Setup mobile menu toggle
 */
function setupMobileMenu() {
    const menuButton = document.getElementById('mobile-menu-button');
    const mobileMenu = document.getElementById('mobile-menu');
    
    if (menuButton && mobileMenu) {
        menuButton.addEventListener('click', function() {
            // Toggle menu visibility
            if (mobileMenu.classList.contains('hidden')) {
                mobileMenu.classList.remove('hidden');
                mobileMenu.classList.add('flex');
                
                // Animate in
                setTimeout(() => {
                    mobileMenu.classList.add('opacity-100');
                    mobileMenu.classList.remove('opacity-0');
                }, 10);
            } else {
                // Animate out
                mobileMenu.classList.remove('opacity-100');
                mobileMenu.classList.add('opacity-0');
                
                setTimeout(() => {
                    mobileMenu.classList.add('hidden');
                    mobileMenu.classList.remove('flex');
                }, 300);
            }
        });
    }
}

/**
 * Setup theme toggle (light/dark mode)
 */
function setupThemeToggle() {
    const themeToggle = document.getElementById('theme-toggle');
    
    if (themeToggle) {
        // Check for saved theme preference or use OS preference
        const savedTheme = localStorage.getItem('theme');
        const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        
        // Set initial theme
        if (savedTheme === 'dark' || (!savedTheme && systemPrefersDark)) {
            document.documentElement.classList.add('dark');
            themeToggle.checked = true;
        }
        
        // Toggle theme when the switch is clicked
        themeToggle.addEventListener('change', function() {
            if (this.checked) {
                document.documentElement.classList.add('dark');
                localStorage.setItem('theme', 'dark');
            } else {
                document.documentElement.classList.remove('dark');
                localStorage.setItem('theme', 'light');
            }
        });
    }
}