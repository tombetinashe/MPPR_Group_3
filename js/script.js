// js/script.js

fetch("https://api.github.com/repos/vincentsd/GWAC-MPPR/contents/submissions/")
    .then(response => response.json())
    .then(data => {
        const submissionsDiv = document.getElementById("submissions");
        data.forEach(file => {
            if (file.name.endsWith(".txt")) {
                const fileLink = document.createElement("a");
                fileLink.href = file.download_url;
                fileLink.textContent = file.name;
                submissionsDiv.appendChild(fileLink);
                submissionsDiv.appendChild(document.createElement("br"));
            }
        });
    });

    // Assuming this script runs when the page loads
const links = document.querySelectorAll('#menu nav ol li a');
links.forEach(link => {
    link.classList.remove('active', 'inactive'); // Reset all
    link.classList.add('inactive'); // Set all to inactive
});

// Set the current link as active
const currentPage = window.location.pathname.split('/').pop();
links.forEach(link => {
    if (link.getAttribute('href') === currentPage) {
        link.classList.add('active'); // Highlight current link
        link.classList.remove('inactive'); // Make it fully visible
    }
});
