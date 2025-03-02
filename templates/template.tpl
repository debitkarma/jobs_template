<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Job Submission and Status</title>
    <script src="https://unpkg.com/htmx.org@1.9.6"></script>
    <!--<script src="static/htmx.min.js"></script>-->
    <style>
        :root {
            --primary-color: #3498db;
            --secondary-color: #2c3e50;
            --background-color: #f4f4f4;
            --card-background: #ffffff;
            --text-color: #333333;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--background-color);
            color: var(--text-color);
            line-height: 1.6;
            margin: 0;
            padding: 20px;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }

        h1,
        h2 {
            color: var(--secondary-color);
        }

        textarea {
            width: 100%;
            height: 150px;
            margin-bottom: 20px;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
            resize: vertical;
        }

        button {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 12px 24px;
            font-size: 16px;
            cursor: pointer;
            border-radius: 4px;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #2980b9;
        }

        .job-status {
            background-color: var(--card-background);
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            margin-top: 30px;
            padding: 20px;
        }

        .job-status h2 {
            margin-top: 0;
            border-bottom: 2px solid var(--primary-color);
            padding-bottom: 10px;
        }

        #job-result {
            margin-top: 20px;
            padding: 10px;
            background-color: #e8f5e9;
            border-radius: 4px;
        }

        ul {
            list-style-type: none;
            padding: 0;
        }

        li {
            background-color: #f8f9fa;
            margin-bottom: 8px;
            padding: 10px;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>

<body>
    <div class="container">
        <h1>Job Submission</h1>

        <form hx-post="/submit" hx-target="#job-result">
            <textarea name="job_data" placeholder="Enter job data here..."></textarea>
            <button type="submit">Submit Job</button>
        </form>

        <div id="job-result"></div>

        <div class="job-status">
            <h2>Running Jobs</h2>
            <div id="running-jobs" hx-get="/running" hx-trigger="load, every 5s"></div>
        </div>

        <div class="job-status">
            <h2>Queued Jobs</h2>
            <div id="queued-jobs" hx-get="/queued" hx-trigger="load, every 5s"></div>
        </div>

        <div class="job-status">
            <h2>Completed Jobs</h2>
            <div id="completed-jobs" hx-get="/completed" hx-trigger="load, every 5s"></div>
        </div>

        <div class="job-status">
            <h2>Failed Jobs</h2>
            <div id="failed-jobs" hx-get="/failed" hx-trigger="load, every 5s"></div>
        </div>
    </div>
</body>

</html>