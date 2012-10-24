*время по секундам
LPARAMETERS tnSeconds as Integer
LOCAL lnDays, lnDays, lnMinutes, lnSeconds, ldDate
	lnDays = INT(m.tnSeconds / 86400)
	lnHours = INT((m.tnSeconds - m.lnDays * 86400) / 3600)
	lnMinutes = INT((m.tnSeconds - m.lnDays * 86400 - m.lnHours * 3600) / 60)
	lnSeconds = m.tnSeconds - (m.lnDays * 86400 + m.lnHours * 3600 + m.lnMinutes * 60)
	
	ldDate = {^1980-01-01} + m.lnDays
RETURN DATETIME(YEAR(m.ldDate), MONTH(m.ldDate), DAY(m.ldDate), m.lnHours, m.lnMinutes, m.lnSeconds)