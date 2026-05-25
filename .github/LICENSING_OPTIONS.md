# Licensing Options For QARDL

This note is not legal advice. It summarizes practical licensing choices for
the QARDL GAUSS library based on the stated goal:

> Allow open use of the GAUSS library, but prevent someone from simply
> translating or porting the library into another language such as R, MATLAB,
> or Python.

## Important Constraint

The current `package.json` lists the license as `MIT`. MIT is a permissive
open-source license and generally allows copying, modification, distribution,
sublicensing, and reuse, including ports or translations.

If the goal is to prevent direct translations or ports, MIT is not a good fit.

There is also a terminology issue: licenses that prohibit derived works,
translations, ports, or certain reimplementations generally are not
Open Source Initiative style "open source" licenses. The Open Source
Definition requires licenses to allow derived works and not discriminate
against fields of endeavor. A no-porting restriction should therefore be
described as **source-available**, **research-available**, or **open-use with
restricted redistribution**, not standard open source.

## What A License Can And Cannot Do

A license can restrict people who receive the QARDL source code from:

- copying the source,
- distributing modified versions,
- distributing direct translations of the source,
- distributing ports that are derivative works of the source,
- removing copyright or citation notices.

A license generally cannot stop someone from independently implementing the
public econometric methods from the academic literature without copying the
QARDL source code. The underlying QARDL method belongs to the published
econometric literature, not exclusively to this software package.

## Practical Options

### Option A: Keep MIT

Best if the priority is maximum adoption.

Pros:

- Familiar to users.
- Accepted by open-source communities.
- Easy for researchers and companies to use.

Cons:

- Does not prevent R, MATLAB, Python, or other ports.
- Does not require scholarly citation beyond preserving legal notices.

### Option B: Strong Copyleft, Such As GPL

Best if the priority is keeping derivatives open.

Pros:

- Allows broad use.
- Requires distributed derivative works to remain under the same license.

Cons:

- Still allows ports and translations.
- May reduce adoption by commercial users.

### Option C: Source-Available Custom License With No-Port Clause

Best fit for the stated goal.

Possible policy:

- Users may use, study, and modify the GAUSS library for internal research,
  teaching, and applied analysis.
- Users may redistribute unmodified copies with attribution and citation
  notices intact.
- Users may not distribute translated, ported, or substantially equivalent
  implementations in another programming language without written permission.
- Users may not remove citation, copyright, or attribution notices.
- Publications, reports, and software comparisons using the library must cite
  the QARDL GAUSS software description and the underlying methodology.

Pros:

- Directly addresses no R/MATLAB/Python translation goal.
- Still allows public inspection and ordinary GAUSS use.
- Allows Aptech to grant exceptions or commercial permissions.

Cons:

- Not OSI open source.
- Custom licenses should be reviewed by counsel.
- Some users, package indexes, or institutions may be cautious about custom
  source-available terms.

### Option D: Dual License

Best if the priority is both public academic use and commercial flexibility.

Possible policy:

- Public source-available license for ordinary GAUSS use.
- Separate written license for ports, embedding, commercial redistribution, or
  derivative products.

Pros:

- Clear path for partnerships or ports with permission.
- Lets Aptech preserve control over translations.

Cons:

- More administrative overhead.
- Requires careful license drafting.

## Recommended Direction

For the stated goal, the best fit is **Option C or D**:

1. Replace `MIT` in `package.json` with a custom license identifier such as
   `QARDL-Source-Available-1.0` or `LicenseRef-QARDL-Source-Available-1.0`.
2. Add a root `LICENSE` file with the custom terms.
3. Keep `CITATION.cff`, `CITATION.md`, and `docs/archive/QARDL_RELEASE_ARTICLE.md`.
4. Add a short README notice:
   - free to use in GAUSS for research, teaching, and applied analysis;
   - citation requested/required by license terms;
   - redistribution of ports/translations requires written permission.
5. Ask counsel to review the final license text before release.

## Draft License Concepts To Review With Counsel

Potential title:

```text
QARDL Source-Available Research License 1.0
```

Potential restricted activity language:

```text
You may not distribute, publish, sublicense, sell, or otherwise make available
any translated, ported, or substantially equivalent implementation of the
Software in another programming language or computational environment,
including but not limited to R, MATLAB, Python, Julia, Stata, or SAS, without
prior written permission from Aptech Systems, Inc.
```

Potential allowed-use language:

```text
You may use the Software in GAUSS for internal research, teaching, evaluation,
commercial analysis, and publication, provided that required copyright,
license, and citation notices are preserved.
```

Potential citation language:

```text
Academic publications, reports, software comparisons, and derivative research
outputs that rely on the Software must cite the QARDL GAUSS software
description and the underlying QARDL methodology identified in CITATION.md.
```

These are drafting concepts, not final legal terms.

## References

- GitHub supports `CITATION.cff` files to help users cite software:
  https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-citation-files
- Citation File Format provides human- and machine-readable software citation
  metadata:
  https://citation-file-format.github.io/
- Zenodo recommends `CITATION.cff` because GitHub uses it to display citation
  suggestions:
  https://help.zenodo.org/docs/github/describe-software/citation-file/
- The Open Source Definition requires derived works to be allowed and bars
  field-of-endeavor restrictions:
  https://opensource.org/osd
