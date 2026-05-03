# Release Checklist

Use this checklist before publishing a GAUSS QARDL release.

1. Confirm `package.json` version matches the intended release artifact.
2. Verify the package manifest:

   ```powershell
   powershell -ExecutionPolicy Bypass -File tests\verify_package_manifest.ps1
   ```

3. Run source-tree GAUSS tests:

   ```powershell
   & 'C:\gauss26\tgauss.exe' -nb -b -x -e 'd="C:\\path\\to\\gauss-qardl\\tests"; chdir ^d; run smoke_public_api.e;'
   & 'C:\gauss26\tgauss.exe' -nb -b -x -e 'd="C:\\path\\to\\gauss-qardl\\tests"; chdir ^d; run smoke_workflow_api.e;'
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
