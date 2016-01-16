# French Part-of-Speech tag and Supertag models

This repository contains the model directories for French Part-of-Speech (POS) and supertags, obtained from the [TLGbank](https://github.com/RichardMoot/TLGbank/) for use with the
[C&C supertagger
  and part-of-speech tagger](http://svn.ask.it.usyd.edu.au/trac/candc/wiki).

### Performance overview of the different models

Performance overview for RichardMoot@c572192846b9c2169ec5ee9198c94d67c3b94adf

##### Supertag models with gold POS tags

Model | Correct (beta=1) | F/w |Correct (beta=0.1) | F/w | Correct (beta=0.05) | F/w | Correct (beta=0.01) | F/w | Correct (beta=0.005)| F/w | Correct (beta=0.001) | F/w
------|---------:|-----------:|-------:|----------:|--------:|----------:|--------:|----------:|--------:|----------:|--------:|---------:
Merged | 90.43 | 1.0 | 96.31  | 1.4 | 97.17 | 1.6 | 98.37 | 2.3 | 98.53 | 2.8 | 98.79 | 4.5
Melt | 90.34 | 1.0 | 96.41 | 1.4 | 97.23 | 1.6 | 98.42 | 2.4 | 98.60 | 2.9 | 98.87 | 4.5
Tt  | 90.08 | 1.0 | 96.23 | 1.4 | 97.16 | 1.6 | 98.39 | 2.4 | 98.56 | 2.9 | 98.83 | 4.6
Simple | 90.13 | 1.0 | 96.32 | 1.4 | 97.21 | 1.6 | 98.43 | 2.4 | 98.60 | 2.9 | 98.86 | 4.6


##### Combined POS- and supertagger

Model | Correct (beta=1) | F/w |Correct (beta=0.1) | F/w | Correct (beta=0.05) | F/w | Correct (beta=0.01) | F/w | Correct (beta=0.005)| F/w | Correct (beta=0.001) | F/w
------|---------:|-----------:|-------:|----------:|--------:|----------:|--------:|----------:|--------:|----------:|--------:|---------:
Merged | 88.73 | 1.0 | 94.75  | 1.4 | 95.67 | 1.6 | 97.24 | 2.4 | 97.56 | 2.8 | 98.06 | 4.5
Melt | 88.74 | 1.0 | 94.82 | 1.4 | 95.72 | 1.6 | 97.22 | 2.4 | 97.54 | 2.9 | 98.09 | 4.5
Tt  | 88.74 | 1.0 | 95.04 | 1.4 | 96.06 | 1.6 | 97.57 | 2.4 | 97.83 | 2.9 | 98.26 | 4.6
Simple | 88.81 | 1.0 | 95.12 | 1.4 | 96.11 | 1.6 | 97.58 | 2.4 | 97.83 | 2.9 | 98.25 | 4.6


##### POS models

Model | Correct |
-----|-----:|
Merged | 97.98 |
Melt | 98.26 |
Tt | 98.42       |
Simple | 98.49 |
