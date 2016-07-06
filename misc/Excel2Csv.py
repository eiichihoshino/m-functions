#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import pandas as pd
import numpy as np
import re
import datetime

def isascii(s):
	if isinstance(s, (str,unicode)):
		return any(ord(c) >= 128 for c in s)
	else:
		return False

if __name__ == '__main__':
	pdDf = pd.read_excel(sys.argv[1])
	pdDf.rename(columns={
	    u'ID':'ID'
	    ,u'性':'gender'
	    ,u'検査日':'testDate'
	    ,u'誕生日':'birthday0'
	    ,u'付記':'NB'
	    ,u'在胎日数':'GA'
	    ,u'日齢：検査時':'dayAgeOnTest'
	    ,u'修正日数':'correctedDayAge'
	    ,u'出生体重(g)':'birthWeight'
	    ,u'体重(検査）':'weightOnTest'
	    ,u'Apgar':'Apgar'
	}, inplace=True)
	
	#add birthday
	days_delta = [datetime.timedelta(days=day) if isinstance(day, int) else np.nan for day in pdDf.dayAgeOnTest]
	days = [day if isinstance(day, datetime.datetime) else pd.tslib.NaT for day in pdDf.testDate]
	pdDf.ix[:,'birthday1'] = pd.Series(days) - pd.Series(days_delta)
	pdDf.ix[:,'birthday'] = [pd.NaT] * len(pdDf)
	for index in pdDf.index:
		if pd.isnull(pdDf.birthday1[index]) or pdDf.birthday0[index] == pdDf.birthday1[index]:
			if isinstance(pdDf.ix[index, 'birthday0'], datetime.datetime):
				pdDf.ix[index,'birthday'] = np.datetime64(pdDf.ix[index, 'birthday0'])
			else:
				pdDf.ix[index,'birthday'] = pd.tslib.NaT
		else:
			pdDf.ix[index,'birthday'] = pdDf.ix[index, 'birthday1']

	#restrict columns
	pdDf = pdDf.ix[:,['ID', 'gender', 'GA', 'birthday']]


	#clean pdDf
	pdDf.GA.replace('-', -1, inplace=True)

	pdDf.ix[map(isascii, pdDf.gender.tolist()), 'gender'] = np.nan
	pdDf.gender.replace('-', np.nan, inplace=True)
	for i in pdDf.index:
		if not isinstance(pdDf.ID[i], (str,unicode)) and np.isnan(pdDf.ID[i]):
			pdDf = pdDf.drop(i)
	pdDf.ID = map(lambda s: s[0] + str(int(s[1:])).zfill(3), pdDf.ID.tolist())
	for i in pdDf.index:
		if not bool(re.match(r'[NE]\d{3}', pdDf.ID[i])):
			print 'Unknown format string %s at index = %d'%(pdDf.ID[i],i)
	pdDf.to_csv(os.path.basename(sys.argv[1]).rsplit('.')[0] + '.csv')
