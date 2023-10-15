# Breadcrumbs

Bugtracker of sorts working off source code.

![](etc/window.png)

Start the app, choose a project folder — it shows a list of all `TODO` and `FIXIT` comments.

`Cmd + O` to open another folder
`Cmd + R` to refresh the list
`Up/Down` to navigate issues

Double click a category to toggle its visibility.

Open in Xcode opens the file in Xcode at the line of the current crumb.

Hashtags in a crumb comment are parsed, click a tag to filter the issues.

Hashtag in the format of "#p{number}" is parsed as the crumb priority, click priority to filter the issues.

The search field filters crumbs by a keyword.

**NB**: This is just a prototype, it's not optimized or architected.