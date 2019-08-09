---
title: "{{ replace (substr .Name 11) "-" " " | title }}"
author: Paul Hammond
type: blog
date: {{ .Date }}
url: /blog/{{ substr .Name 11 }}/
categories:
  - Blog
tags:
  - tag1
  - tag2
  - tag3
resources:
- name: featured
  src: images/featured.jpg
  title: featured
draft: true
---
