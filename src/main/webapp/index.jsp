<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>Welcome - PahanEdu Bookshop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        html, body {
            margin: 0;
            padding: 0;
            height: 100%;
            overflow: hidden;
            font-family: 'Segoe UI', sans-serif;
            background-color: #000;
        }

        #particles-js {
            position: absolute;
            width: 100%;
            height: 100%;
            z-index: 0;
        }

        .center-content {
            position: relative;
            z-index: 1;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            color: white;
        }

        svg.lock-icon {
            width: 100px;
            height: 100px;
            cursor: pointer;
            stroke-dasharray: 400;
            stroke-dashoffset: 400;
            animation: draw 3s forwards ease-in-out;
        }

        @keyframes draw {
            to {
                stroke-dashoffset: 0;
            }
        }

        .welcome-text {
            margin-top: 20px;
            font-size: 1.5rem;
            text-align: center;
        }
    </style>
</head>
<body>

<div id="particles-js"></div>

<div class="center-content">
    <!-- Lock SVG with animation -->
    <svg onclick="navigateToDashboard()" class="lock-icon" viewBox="0 0 24 24" fill="none" stroke="#00f7ff"
         stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
    </svg>

    <div class="welcome-text">Click the Lock to Enter PahanEdu Bookshop</div>
</div>

<!-- Particle.js -->
<script src="https://cdn.jsdelivr.net/npm/particles.js@2.0.0/particles.min.js"></script>
<script>
    particlesJS("particles-js", {
        "particles": {
            "number": {
                "value": 60,
                "density": { "enable": true, "value_area": 800 }
            },
            "color": { "value": "#00f7ff" },
            "shape": { "type": "circle" },
            "opacity": {
                "value": 0.5,
                "random": true
            },
            "size": {
                "value": 4,
                "random": true
            },
            "line_linked": {
                "enable": true,
                "distance": 150,
                "color": "#00f7ff",
                "opacity": 0.4,
                "width": 1
            },
            "move": {
                "enable": true,
                "speed": 2,
                "direction": "none",
                "out_mode": "out"
            }
        },
        "interactivity": {
            "events": {
                "onhover": { "enable": true, "mode": "grab" },
                "onclick": { "enable": true, "mode": "push" }
            }
        },
        "retina_detect": true
    });

    function navigateToDashboard() {
        window.location.href = "login.jsp";
    }
</script>

</body>
</html>
