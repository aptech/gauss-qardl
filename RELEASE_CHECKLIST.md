# Release Checklist

Use this checklist before publishing a GAUSS QARDL release.

## Citation And License

- Confirm `CITATION.cff`, `CITATION.md`, and
  `docs/QARDL_RELEASE_ARTICLE.md` match the release version, date, URL, and
  preferred citation.
- Finalize the public license before publishing. If the intended policy is open
  GAUSS use without direct ports to R, MATLAB, Python, or other languages,
  review `docs/LICENSING_OPTIONS.md`, add the final root `LICENSE`, and ensure
  `package.json` uses the same license identifier.

## Release Steps

1. Confirm `package.json` version matches the intended release artifact.
2. Run the source-tree release gate:

   ```powershell
   powershell -ExecutionPolicy Bypass -File tests\run_source_tests.ps1
   ```

3. Run the modern example smoke suite:

   ```powershell
   powershell -ExecutionPolicy Bypass -File tests\run_examples_smoke.ps1
   ```

4. Build/reinstall the GAUSS application package.
5. Run the installed-package release gate:

   ```powershell
   & 'C:\gauss26\tgauss.exe' -nb -b -x -e 'd="C:\\path\\to\\gauss-qardl\\tests"; chdir ^d; run package_public_api.e;'
   ```

6. Create the release zip named for the package version, for example
   `qardl_3.0.0.zip`.
7. Update `CHANGELOG.md`, `README.md`, and `GOLD_STANDARD_TODO.md`.
8. Attach the zip to the GitHub Release or commit it only if release artifacts
   are intentionally tracked in this repository.
