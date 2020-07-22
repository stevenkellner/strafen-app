import json
import random
import uuid
import datetime
import string

# Get person file content
personFile = open("person.json", "r")
personContent = personFile.read()
personFile.close()

# Get reason file content
reasonFile = open("reason.json", "r")
reasonContent = reasonFile.read()
reasonFile.close()

# Get person and reason list
personList = json.loads(personContent)
reasonList = json.loads(reasonContent)
personIdList = map(lambda person: person["id"], personList)
reasonIdList = map(lambda reason: reason["id"], reasonList)

# Init fine list
fineList = []

# Generates new fine
def generateFine():
    
    # Init fine
    fine = {}
    
    # Add id
    fine['id'] = str(uuid.uuid4())
    
    # Add personId
    fine['personId'] = random.choice(personIdList)
    
    # Add date
    startDate = datetime.date(2000, 1, 1)
    endDate = datetime.date(2020, 1, 1)
    timeBetweenDates = endDate - startDate
    daysBetweenDates = timeBetweenDates.days
    randomNumberOfDays = random.randrange(daysBetweenDates)
    randomDate = startDate + datetime.timedelta(days=randomNumberOfDays)
    dateString = randomDate.strftime('%d.%m.%Y')
    fine['date'] = dateString
    
    # Add number
    fine['number'] = random.randint(1, 10)
    
    # Add payed
    fine['payed'] =  random.choice([True, False])
    
    # Add reason, importance, amount or template
    if random.uniform(0, 1) <= 0.75 :
    
        # from template
        fine['templateId'] = random.choice(reasonIdList)
        fine['reason'] = None
        fine['importance'] = None
        fine['amount'] = None
        
    else:
        
        # reason, importance, amount
        fine['templateId'] = None
        fine['reason'] = ''.join(random.choice(string.ascii_lowercase) for i in range(random.randint(10, 20)))
        fine['importance'] = random.choice(['high', 'medium', 'low'])
        fine['amount'] = round(random.uniform(0.1, 50) * 100) / 100
    
    return fine

# Generate 50 - 100 fines
for i in range(random.randint(50, 100)):
    fineList.append(generateFine())
    
# Write to fine file
reasonFile = open("fine.json", "w")
reasonContent = reasonFile.write(json.dumps(fineList))
reasonFile.close()
