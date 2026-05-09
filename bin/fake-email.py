#!/usr/bin/env python3

import random

domains = ["gmail.com", "yahoo.com", "outlook.com", "proton.me"]
names = ["alex", "sam", "john", "maria", "lisa", "david"]

emails = [
    f"{random.choice(names)}{random.randint(1,9999)}@{random.choice(domains)}"
    for _ in range(1000)
]

with open("fake_emails.txt", "w") as f:
    f.write("\n".join(emails))
    
