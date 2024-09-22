// js/script.js

fetch("https://api.github.com/repos/vincentsd/GWAC-MPPR/contents/")
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
