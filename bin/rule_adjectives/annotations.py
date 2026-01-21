#!/usr/bin/env python
"""
Tool to parse the annotations file, and store it in
convenient transformations.
"""
import re
import pandas as pd
from collections import Counter
from itertools import chain
import os
from dram_viz.definitions import (
    ID_FUNCTION_DICT as FUNCTION_DICT,
    SULFUR_ID,
    FEGENIE_ID
)
# import dask.dataframe as dd

FASTA_COLUMN = os.getenv('FASTA_COLUMN', 'input_fasta')


def get_ids_from_annotations_by_row(data):
    missing = [i for i in FUNCTION_DICT if i not in data.columns]
    functions = {i:j for i,j in FUNCTION_DICT.items() if i in data.columns}
    print("Note: the following id fields "
          f"were not in the annotations file and are not being used: {missing},"
          f" but these are {list(functions.keys())}")
    out = data.apply(lambda x: {i for k, v in functions.items() if not pd.isna(x[k])
                                for i in v(str(x[k])) if not pd.isna(i)}, axis=1)
    return out


def get_ids_from_annotation(frame):
    print('geting ids from annotations')
    return Counter(chain(*frame.apply(get_ids_from_row, axis=1).values))


class Annotations():

    def __init__(self, annotations_tsv:str):
        self.ids_by_fasta = None
        self.ids_by_row = None
        self.data = pd.read_csv(annotations_tsv, sep='\t', index_col=0, low_memory=False)
        self.data.set_index([FASTA_COLUMN, self.data.index], inplace=True)
        self.set_annotation_ids_by_row()
        self.set_annotations(annotations_tsv)

    def set_annotations(self, annotations_tsv:str):
        data = self.ids_by_row.copy()
        data['annotations'] = data['annotations'].apply(list)
        annot_fasta_ids = data.groupby(FASTA_COLUMN)
        annot_fasta_ids = annot_fasta_ids.apply(lambda x: Counter(chain(*x['annotations'].values)))
        annot_fasta_ids = pd.DataFrame(annot_fasta_ids, columns=['annotations'])
        self.ids_by_fasta = annot_fasta_ids

    def set_annotation_ids_by_row(self):
        # self.raw_annotations = anno_data
        print("generating IDs by index, this may take some time")
        data = self.data.copy()
        # data.set_index([FASTA_COLUMN, data.index], inplace=True)
        annot_ids = get_ids_from_annotations_by_row(self.data)
        annot_ids = pd.DataFrame(annot_ids, columns=['annotations'])
        self.ids_by_row = annot_ids
