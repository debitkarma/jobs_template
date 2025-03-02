<ul>
    % for job in jobs:
    <li>{{job.id}} - {{job.latest_result().return_value}}</li>
    % end
</ul>