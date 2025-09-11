# React Code Generation Guidelines

These guidelines provide a structured approach for generating high-quality, maintainable React code, specifically for translating Figma designs into functional React components and pages in a Next.js project. The focus is on adhering to design specifications, following React best practices, and ensuring code reusability and consistency.

## Table of Contents

1. [Role and Objectives](#role-and-objectives)

2. [Core Principles](#core-principles)

3. [Component Development Guidelines](#component-development-guidelines)

   - [Figma-First Approach](#figma-first-approach)

   - [Component Decomposition and Reusability](#component-decomposition-and-reusability)

   - [Code Redundancy Elimination](#code-redundancy-elimination)

   - [React Best Practices](#react-best-practices)

4. [Modal Component System](#modal-component-system)

   - [Architecture Overview](#architecture-overview)

   - [Component API](#component-api)

   - [Implementation Strategy](#implementation-strategy)

   - [Close Button Handling](#close-button-handling)

   - [Example Usage](#example-usage)

5. [UI Documentation Guidelines](#ui-documentation-guidelines)

   - [Documentation Structure](#documentation-structure)

   - [Visual Specification Details](#visual-specification-details)

6. [Folder and Component Structure](#folder-and-component-structure)

7. [State Management](#state-management)

8. [Code Style and Formatting](#code-style-and-formatting)]

9. [Image Placeholder Guidelines]

10. [Available Components](#available-components)

11. [Curated Example of Some Components]

---

## Role and Objectives

As a senior React developer, your primary objective is to:

- **Translate Figma designs** into pixel-perfect, functional React components and pages.

- **Ensure code quality** by adhering to React best practices, maintaining consistency, and promoting reusability.

- **Follow the provided guidelines** to produce clean, modular, and maintainable code that aligns with the project's architecture.

---

## Core Principles

1. **Design Fidelity**: Treat Figma designs and their exported CSS as the single source of truth for visual specifications.

2. **Reusability**: Prioritize existing components and create new ones only when necessary, ensuring modularity and consistency.

3. **Maintainability**: Write clean, readable code with clear separation of concerns and minimal redundancy.

4. **Best Practices**: Follow modern React conventions, including functional components, hooks, and proper state management.

---

## Component Development Guidelines

### Figma-First Approach

- **Adhere to Figma Specifications**: Implement layouts, sizes, colors, and typography exactly as specified in the Figma design and exported CSS.

- **Pixel-Perfect Implementation**: Ensure the rendered UI matches the design down to the pixel, paying attention to spacing, alignment, and visual details.

- **Tailwind CSS**: Use Tailwind CSS classes from `tailwind.config.mjs` for styling. Avoid inline styles or custom `.scss` files unless explicitly required.

### Component Decomposition and Reusability

- **Identify Patterns**: Analyze the Figma design for repeating UI elements (e.g., cards, lists, buttons) and extract them into reusable components.

- **Search Existing Components**: Before creating a new component, check the `src/components` directory for existing components that match the design.

- **Modular Design**: Break down complex UIs into smaller, reusable components (atoms, molecules, organisms) with single responsibilities.

- **Example**:

  ```jsx
  // Good: Reusable ProductItem component

  const ProductList = ({ products }) => (
    <div className="grid grid-cols-3 gap-4">
      {products.map((product) => (
        <ProductItem key={product.id} product={product} />
      ))}
    </div>
  );

  // Bad: Repeated markup inline

  const ProductList = ({ products }) => (
    <div className="grid grid-cols-3 gap-4">
      {products.map((product) => (
        <div key={product.id} className="p-4 border rounded">
          <h3>{product.name}</h3>

          <p>{product.price}</p>
        </div>
      ))}
    </div>
  );
  ```

### Code Redundancy Elimination

- **Extract Repeated Logic**: Move complex or repeated logic into custom hooks (e.g., `useModalState`, `useFormValidation`).

- **Compose Components**: Build complex components by composing simpler ones to reduce duplication.

- **Keep Components Focused**: Ensure each component has a single responsibility and minimal file size.

### React Best Practices

- **Functional Components**: Use functional components with hooks (`useState`, `useEffect`, etc.) instead of class components.

- **State Management**: Prefer `useState` for local state and lift state up to the nearest common ancestor when needed.

- **Context API**: Use the Context API for shared state across components when prop drilling becomes cumbersome.

- **Clean Code**: Write readable, well-documented code with consistent formatting (use Prettier and ESLint).

- **Error Handling**: Implement proper error boundaries and fallback UIs for robust applications.

---

## Modal Component System

The Modal component system follows a compound component pattern, ensuring a consistent and declarative API for modal implementations.

### Architecture Overview

- **Compound Component Pattern**: The `<Modal>` component manages visibility state and shares it with its children (`<ModalTrigger>`, `<ModalContent>`, `<ModalHeader>`) via context.

- **Non-Standalone Children**: Child components (`<ModalTrigger>`, `<ModalContent>`, `<ModalHeader>`) cannot be used outside the `<Modal>` context.

- **State Management**: Supports both controlled (via `open` and `onOpenChange`) and uncontrolled (internal state) modes.

### Component API

| Component | Purpose | Key Props | Constraints |

| -------------------- | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |

| **`<Modal>`** | Root component managing modal state and context. | `open` (boolean), `onOpenChange` (function), `closeOnOutsideClick` (boolean) | Use `open` and `onOpenChange` for controlled modals; omit for uncontrolled. |

| **`<ModalTrigger>`** | Wraps the element that triggers the modal. | Accepts a single React element as children. | Must be a direct child of `<Modal>`. The child element (e.g., `<button>`) is the interactive trigger. |

| **`<ModalContent>`** | Container for modal content, including header, body, and footer. | `className` (string), `type` ('muatmuat' \| 'muatparts') | Renders a built-in close button (X icon). Do **not** add custom close buttons. |

| **`<ModalHeader>`** | Presentational component for rendering a pre-styled header with a background image. | `size` ('small' \| 'big' \| 'xl') | Self-closing; does **not** accept children. Used only when a background image is present. Title is a sibling element. |

### Implementation Strategy

The modal implementation depends on the presence of a `background-image` in the header design, determined by analyzing the Figma export or CSS.

#### Scenario A: Pre-Styled Modal with `<ModalHeader>`

- **Condition**: Header has a `background-image`.

- **Steps**:

  1. Use `<ModalHeader>` with the appropriate `size` prop ('small', 'big', 'xl') based on the image dimensions.

  2. Apply the corresponding `className` to `<ModalContent>` (e.g., `w-modal-small` for `size="small"`).

  3. Place `<ModalHeader />` as the first child of `<ModalContent>`.

  4. Add the title (e.g., `<h2>`) as a sibling after `<ModalHeader>`.

  **Size Mapping**:

  | `ModalHeader` `size` | `ModalContent` `className` | Description |

  |----------------------|---------------------------|------------------------------------------|

  | `small` | `w-modal-small` | Small header background image. |

  | `big` | `w-modal-big` | Large header background image. |

  | `xl` | `w-modal-xl` | Extra-large header background image. |

#### Scenario B: Custom Modal without `<ModalHeader>`

- **Condition**: Header has no `background-image` (solid color or transparent).

- **Steps**:

  1. Omit `<ModalHeader>`.

  2. Set `<ModalContent>` width using an arbitrary Tailwind class (e.g., `w-[578px]`).

  3. Create the header using semantic HTML (e.g., `<h2>`) as the first child of `<ModalContent>`.

  4. Apply header styles directly using Tailwind classes.

### Close Button Handling

- **Built-In Close Button**: `<ModalContent>` automatically renders a close button (X icon) in the top-right corner.

- **Strict Rule**: **Do not** add custom close buttons or `onClick` handlers for closing within `<ModalContent>`.

- **Examples to Avoid**:

  ```jsx
  // DO NOT DO THIS

  <ModalContent>
    <button onClick={closeModal}>Close</button> {/* Invalid */}
    <Icon name="close" onClick={closeModal} /> {/* Invalid */}
  </ModalContent>
  ```

### Example Usage of Modal Component

```jsx
import Link from "next/link";

import React, { useMemo, useState } from "react";

import { Alert } from "@/components/Alert/Alert";

import { AvatarDriver } from "@/components/Avatar/AvatarDriver";

import { BadgeStatusPesanan } from "@/components/Badge/BadgeStatusPesanan";

import { BannerCarousel } from "@/components/BannerCarousel/BannerCarousel";

import {
  BottomSheet,
  BottomSheetClose,
  BottomSheetContent,
  BottomSheetHeader,
  BottomSheetTitle,
  BottomSheetTrigger,
} from "@/components/BottomSheet/BottomSheetUp";

import BreadCrumb from "@/components/Breadcrumb/Breadcrumb";

import Button from "@/components/Button/Button";

import { ButtonMini } from "@/components/Button/ButtonMini";

import Card, {
  CardContent,
  CardFooter,
  CardHeader,
  ListContent,
} from "@/components/Card/Card";

import DataEmpty from "@/components/DataEmpty/DataEmpty";

import DataNotFound from "@/components/DataNotFound/DataNotFound";

import DatetimePicker from "@/components/DatetimePicker/DatetimePicker";

import Dropdown from "@/components/Dropdown/Dropdown";

import { DropdownJasaPengiriman } from "@/components/Dropdown/DropdownJasaPengiriman";

import DropdownRadioBottomsheeet from "@/components/Dropdown/DropdownRadioBottomsheeet";

import DropdownPeriode from "@/components/DropdownPeriode/DropdownPeriode";

import FileUpload from "@/components/FileUpload/FileUpload";

import Checkbox from "@/components/Form/Checkbox";

import { DimensionInput } from "@/components/Form/DimensionInput";

import { FormContainer, FormLabel } from "@/components/Form/Form";

import { InfoBottomsheet } from "@/components/Form/InfoBottomsheet";

import { InfoTooltip } from "@/components/Form/InfoTooltip";

import { NumberInput } from "@/components/Form/NumberInput";

import { Select } from "@/components/Form/Select";

import { TagInput } from "@/components/Form/TagInput";

import { MyTextArea } from "@/components/Form/TextArea";

import IconComponent from "@/components/IconComponent/IconComponent";

import ImageUploaderWeb from "@/components/ImageUploader/ImageUploaderWeb";

import ImagesPreview from "@/components/ImagesPreview/ImagesPreview";

import { InputSearch } from "@/components/InputSearch/InputSearch";

import {
  LightboxPreview,
  LightboxProvider,
} from "@/components/Lightbox/Lightbox";

import { MapContainer } from "@/components/MapContainer/MapContainer";

import { MapWithPath } from "@/components/MapContainer/MapWithPath";

import {
  Modal,
  ModalContent,
  ModalHeader,
  ModalTrigger,
} from "@/components/Modal/Modal";

import PageTitle from "@/components/PageTitle/PageTitle";

import QuantityInput from "@/components/QuantityInput/QuantityInput";

import RadioButton from "@/components/Radio/RadioButton";

import { Slider } from "@/components/Slider/Slider";

import SortingDropdown from "@/components/SortingDropdown/SortingDropdown";

import {
  StepperContainer,
  StepperItemResponsive,
} from "@/components/Stepper/Stepper";

import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
  TabsTriggerWithSeparator,
} from "@/components/Tabs/Tabs";

import TextArea from "@/components/TextArea/TextArea";

import { NewTimelineItem, TimelineContainer } from "@/components/Timeline";

import TimelineField from "@/components/Timeline/timeline-field";

import Toggle from "@/components/Toggle/Toggle";

import RequestOtp from "@/container/Shipper/RequestOtp/RequestOtp";

import { useTranslation } from "@/hooks/use-translation";

import { toast } from "@/lib/toast";

import {
  dataCollapsed,
  dataCollapsedWithDate,
  dataMuatBongkar,
  fakeAddress,
} from "./mockdata";

const imagesPreviewList = [
  "https://picsum.photos/400/300?random=1",

  "https://picsum.photos/400/300?random=2",

  "https://picsum.photos/400/300?random=3",

  "https://picsum.photos/400/300?random=4",
];

const ExampleWeb = () => {
  const [imagesPreviewOpen, setImagesPreviewOpen] = useState(false);

  const [imagesPreviewActiveIndex, setImagesPreviewActiveIndex] = useState(0);

  const [mapCoordinates, setMapCoordinates] = useState({
    latitude: -7.2575,

    longitude: 112.7521,
  });

  const [otpNotification, setOtpNotification] = useState(null);

  const [selectedProvinces, setSelectedProvinces] = useState([]);

  const [provinceIds] = useState([11, 12, 13, 14, 15]); // Example province IDs

  const tabMenuItems = [
    { id: 1, name: "Tab Satu", notif: 2 },

    { id: 2, name: "Tab Dua", notif: 0 },

    { id: 3, name: "Tab Tiga", notif: 101 },
  ];

  const [tabMenuSelectedId, setTabMenuSelectedId] = useState(
    tabMenuItems[0].id
  );

  const handleTabChange = (id) => setTabMenuSelectedId(id);

  return (
    <div className="grid grid-cols-1 gap-8 bg-white md:px-8">
      <AlertBadge />

      <ExampleBanner />

      <BreadcrumbCardStepper />

      <ButtonBottomsheetTooltipForm />

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        <div>
          <h1 className="mb-2 text-xl font-bold">Data Empty</h1>

          <DataEmpty
            title="No Search Results"
            subtitle="We couldn't find any products matching your search criteria. Try adjusting your search terms."
            buttonText="Search Again"
            iconPlus={false}
            onButtonClick={() => alert("Search again clicked")}
          />
        </div>

        <div>
          <h1 className="mb-2 text-xl font-bold">Data Not Found</h1>

          <div className="rounded-lg border border-neutral-200 p-8">
            <DataNotFound type="search" title="No Search Results Found" />
          </div>
        </div>
      </div>

      <ExampleLightbox />

      <ExampleTimeline />

      <ExampleInput />

      <div className="w-full">
        <h1 className="mb-2 text-xl font-bold">Date Time Picker</h1>

        <div className="grid grid-cols-1 gap-8 md:grid-cols-3">
          <div>
            <h2 className="mb-2 text-sm font-medium">Default</h2>

            <DatetimePicker
              datetimeValue={new Date()}
              onApply={(date) => alert("Applied date:", date)}
              onCancel={(date) => alert("Cancelled date:", date)}
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">With Min Date</h2>

            <DatetimePicker
              datetimeValue={new Date()}
              minDate={new Date()}
              onApply={(date) => alert("Applied date:", date)}
              onCancel={(date) => alert("Cancelled date:", date)}
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">With Max Date</h2>

            <DatetimePicker
              datetimeValue={new Date()}
              maxDate={new Date(new Date().setDate(new Date().getDate() + 7))}
              onApply={(date) => alert("Applied date:", date)}
              onCancel={(date) => alert("Cancelled date:", date)}
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">Disabled</h2>

            <DatetimePicker
              datetimeValue={new Date()}
              disabled={true}
              onApply={(date) => alert("Applied date:", date)}
              onCancel={(date) => alert("Cancelled date:", date)}
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">Error State</h2>

            <DatetimePicker
              datetimeValue={new Date()}
              status="error"
              onApply={(date) => alert("Applied date:", date)}
              onCancel={(date) => alert("Cancelled date:", date)}
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">Custom Format</h2>

            <DatetimePicker
              datetimeValue={new Date()}
              dateFormat="dd/MM/yyyy HH:mm"
              onApply={(date) => alert("Applied date:", date)}
              onCancel={(date) => alert("Cancelled date:", date)}
            />
          </div>
        </div>
      </div>

      <div className="w-full">
        <h1 className="mb-2 text-xl font-bold">Dropdown</h1>

        <div className="grid grid-cols-1 gap-8 md:grid-cols-2">
          <div>
            <h2 className="mb-2 text-sm font-medium">Basic Dropdown</h2>

            <Dropdown
              options={[
                { name: "Option 1", value: "1" },

                { name: "Option 2", value: "2" },

                { name: "Option 3", value: "3" },
              ]}
              placeholder="Select an option"
              onSelected={(selected) => alert("Selected:", selected)}
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">With Search</h2>

            <Dropdown
              options={[
                { name: "Apple", value: "apple" },

                { name: "Banana", value: "banana" },

                { name: "Orange", value: "orange" },

                { name: "Mango", value: "mango" },
              ]}
              placeholder="Search fruits..."
              onSearchValue={(value) => alert("Search:", value)}
              onSelected={(selected) => alert("Selected:", selected)}
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">Multiple Selection</h2>

            <Dropdown
              options={[
                { name: "Red", value: "red" },

                { name: "Blue", value: "blue" },

                { name: "Green", value: "green" },

                { name: "Yellow", value: "yellow" },
              ]}
              placeholder="Select colors"
              isMultipleSelected={true}
              onSelected={(selected) => alert("Selected:", selected)}
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">With Custom Option</h2>

            <Dropdown
              options={[
                { name: "Option 1", value: "1" },

                { name: "Option 2", value: "2" },
              ]}
              optionsOther={[
                { name: "Other Option 1", value: "other1" },

                { name: "Other Option 2", value: "other2" },
              ]}
              optionsOtherText="More Options"
              placeholder="Select with custom"
              onSelected={(selected) => alert("Selected:", selected)}
              onClickTextOther={() => alert("Other options clicked")}
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">With Icons</h2>

            <Dropdown
              options={[
                {
                  name: "Settings",

                  value: "settings",

                  title: "Account Settings",
                },

                {
                  name: "Profile",

                  value: "profile",

                  title: "User Profile",
                },
              ]}
              placeholder="Select with icons"
              leftIconElement={<IconComponent src="/icons/settings.svg" />}
              onSelected={(selected) => alert("Selected:", selected)}
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">Error State</h2>

            <Dropdown
              options={[
                { name: "Option 1", value: "1" },

                { name: "Option 2", value: "2" },
              ]}
              placeholder="Select an option"
              isError={true}
              onSelected={(selected) => alert("Selected:", selected)}
            />
          </div>
        </div>
      </div>

      <div className="w-full">
        <h1 className="mb-2 text-xl font-bold">Dropdown Radio Bottomsheet</h1>

        <div className="grid grid-cols-1 gap-8 md:grid-cols-2">
          <div>
            <h2 className="mb-2 text-sm font-medium">Basic Dropdown Radio</h2>

            <DropdownRadioBottomsheeet
              className="w-full"
              title="Select Option"
              options={[
                { label: "Option 1", value: "1" },

                { label: "Option 2", value: "2" },

                { label: "Option 3", value: "3" },
              ]}
              value="1"
              onChange={(value) => alert("Selected:", value)}
              saveLabel="Save"
              placeHolder="Select an option"
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">Postal Code Example</h2>

            <DropdownRadioBottomsheeet
              className="w-full"
              title="Kode Pos"
              options={[
                { label: "60261", value: "60261" },

                { label: "60262", value: "60262" },

                { label: "60263", value: "60263" },

                { label: "60264", value: "60264" },

                { label: "60265", value: "60265" },
              ]}
              value="60261"
              onChange={(value) => alert("Selected postal code:", value)}
              saveLabel="Simpan"
              placeHolder="Pilih Kode Pos"
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">With Custom Width</h2>

            <DropdownRadioBottomsheeet
              className="w-[200px]"
              title="Select Size"
              options={[
                { label: "Small", value: "S" },

                { label: "Medium", value: "M" },

                { label: "Large", value: "L" },

                { label: "Extra Large", value: "XL" },
              ]}
              value="M"
              onChange={(value) => alert("Selected size:", value)}
              saveLabel="Apply"
              placeHolder="Choose size"
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">With Long Options</h2>

            <DropdownRadioBottomsheeet
              className="w-full"
              title="Select Category"
              options={[
                { label: "Electronics and Gadgets", value: "electronics" },

                { label: "Fashion and Apparel", value: "fashion" },

                { label: "Home and Living", value: "home" },

                { label: "Sports and Outdoor", value: "sports" },

                { label: "Books and Stationery", value: "books" },
              ]}
              value="electronics"
              onChange={(value) => alert("Selected category:", value)}
              saveLabel="Confirm"
              placeHolder="Select category"
            />
          </div>
        </div>
      </div>

      <div className="w-full">
        <h1 className="mb-2 text-xl font-bold">Dropdown Periode</h1>

        <div className="grid grid-cols-1 gap-8 md:grid-cols-2">
          <div>
            <h2 className="mb-2 text-sm font-medium">Basic Period Selection</h2>

            <DropdownPeriode
              options={[
                { name: "Hari Ini", value: "today" },

                { name: "7 Hari Terakhir", value: "last7days" },

                { name: "30 Hari Terakhir", value: "last30days" },

                { name: "Bulan Ini", value: "thisMonth" },
              ]}
              onSelect={(selected) => alert("Selected period:", selected)}
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">With Recent Selections</h2>

            <DropdownPeriode
              options={[
                { name: "Hari Ini", value: "today" },

                { name: "7 Hari Terakhir", value: "last7days" },

                { name: "30 Hari Terakhir", value: "last30days" },

                { name: "Bulan Ini", value: "thisMonth" },
              ]}
              recentSelections={[
                { name: "01/03/2024 - 15/03/2024", value: "custom1" },

                { name: "16/02/2024 - 29/02/2024", value: "custom2" },
              ]}
              onSelect={(selected) => alert("Selected period:", selected)}
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">Disabled State</h2>

            <DropdownPeriode
              options={[
                { name: "Hari Ini", value: "today" },

                { name: "7 Hari Terakhir", value: "last7days" },

                { name: "30 Hari Terakhir", value: "last30days" },

                { name: "Bulan Ini", value: "thisMonth" },
              ]}
              disable={true}
              onSelect={(selected) => alert("Selected period:", selected)}
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">With Custom Width</h2>

            <div className="w-[300px]">
              <DropdownPeriode
                options={[
                  { name: "Hari Ini", value: "today" },

                  { name: "7 Hari Terakhir", value: "last7days" },

                  { name: "30 Hari Terakhir", value: "last30days" },

                  { name: "Bulan Ini", value: "thisMonth" },
                ]}
                onSelect={(selected) => alert("Selected period:", selected)}
              />
            </div>
          </div>
        </div>
      </div>

      <div>
        <h1 className="mb-2 text-xl font-bold">Images Preview</h1>

        <button
          className="mb-4 rounded bg-primary-700 px-4 py-2 text-white"
          onClick={() => setImagesPreviewOpen(true)}
        >
          Open Images Preview
        </button>

        <ImagesPreview
          images={imagesPreviewList}
          isOpen={imagesPreviewOpen}
          setIsOpen={setImagesPreviewOpen}
          activeIndex={imagesPreviewActiveIndex}
          setActiveIndex={setImagesPreviewActiveIndex}
        />
      </div>

      <div>
        <h1 className="mb-2 text-xl font-bold">Tab Menu Example</h1>

        <div className="mb-2">
          <div className="flex w-[386px] bg-white">
            {tabMenuItems.map((item, idx) => (
              <React.Fragment key={item.id}>
                {idx > 0 && (
                  <div className="border-l border-l-neutral-400"></div>
                )}

                <div
                  className={`mx-1 flex-shrink-0 flex-grow cursor-pointer px-6 py-1 text-base sm:mx-0 sm:max-w-[50%] sm:px-0 sm:text-center sm:text-sm ${
                    tabMenuSelectedId === item.id
                      ? "border-b-2 border-b-primary-700 font-bold text-primary-700"
                      : "font-semibold text-neutral-900"
                  }`}
                  onClick={() => handleTabChange(item.id)}
                >
                  {`${item.name} (${item.notif >= 100 ? "99+" : item.notif})`}
                </div>
              </React.Fragment>
            ))}
          </div>
        </div>

        <div className="mt-2 text-xs text-neutral-500">
          Selected Tab:{" "}
          {tabMenuItems.find((item) => item.id === tabMenuSelectedId)?.name}
        </div>
      </div>

      <MapExample />

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        <div className="w-[700px]">
          <h1 className="mb-2 text-xl font-bold">Pilih Provinsi Example</h1>

          <iframe
            src="/example/pilihprovinsi"
            style={{
              width: "100%",

              height: 700,

              border: "1px solid #eee",

              borderRadius: 8,

              background: "#fff",
            }}
            title="Pilih Provinsi Example"
          />
        </div>

        <div className="border p-4">
          <h1 className="mb-2 text-xl font-bold">Slider Example</h1>

          <div className="w-full px-6 py-9">
            <Slider.Root
              items={[
                {
                  title: "Unggah Armada Massal",

                  imgSrc:
                    "/img/tambah-armada-massal/popupinformasi-slider-1.png",

                  content:
                    "Kamu bisa mengunggah armada secara massal menggunakan fitur ini.",
                },

                {
                  title: "Unggah Armada Massal",

                  imgSrc:
                    "/img/tambah-armada-massal/popupinformasi-slider-2.png",

                  content:
                    "Ada dua pilihan untuk mengunggah armada secara massal : <ol><li>Menggunakan file excel</li><li>Mengisi kolom yang sudah tersedia</li></ol>",
                },

                {
                  title: "Unggah Dengan Excel",

                  imgSrc:
                    "/img/tambah-armada-massal/popupinformasi-slider-3.png",

                  content:
                    "Kamu bisa mengunggah dengan langkah :<ol><li>Unduh template</li><li>Isi kolom yang tersedia (kamu bisa melihat contoh sheet prosedur)</li><li>Unggah file excel di kolom yang tersedia</li></ol>",
                },

                {
                  title: "Isi Kolom Massal",

                  imgSrc:
                    "/img/tambah-armada-massal/popupinformasi-slider-4.png",

                  content:
                    "Kamu bisa mengunggah dengan langkah :<ol><li>Isi kolom yang tersedia</li><li>Klik Simpan (jika ingin menambah armada klik button Tambah padahalaman tersebut)</li></ol>",
                },
              ]}
              className="flex h-[322px] flex-col items-center justify-center gap-6 p-6"
            >
              {/* A relative container is needed for the absolutely positioned navigation */}

              <div className="relative flex w-full items-center justify-center">
                <Slider.DesktopNavigation />

                <Slider.Content className="h-[120px] w-[120px]">
                  {(item) => (
                    <div className="flex h-full items-center justify-center">
                      <img
                        src={item.imgSrc}
                        alt={item.title}
                        className="h-full w-full object-contain"
                      />
                    </div>
                  )}
                </Slider.Content>
              </div>

              <div className="text-center">
                <Slider.Title className="mb-3 text-lg font-bold text-neutral-900" />

                <Slider.Description className="text-sm font-medium text-neutral-900" />
              </div>

              <Slider.Indicator className="mt-auto" />
            </Slider.Root>
          </div>
        </div>
      </div>

      <div>
        <h1 className="mb-2 text-xl font-bold">OTP Rekening Web Example</h1>

        <RequestOtp dontRedirect />
      </div>

      <TabsExample />
    </div>
  );
};

export default ExampleWeb;

const AlertBadge = () => {
  return (
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
      <div className="flex flex-wrap gap-4">
        <div>
          <h1 className="mb-2 text-xl font-bold">Alert</h1>

          <Alert variant="warning" className="mb-4 w-[250px]">
            Lorem ipsum, dolor sit amet consectetur adipisicing elit. Mollitia
            sint nihil numquam perspiciatis!
          </Alert>
        </div>

        <div>
          <h1 className="mb-2 text-xl font-bold">Avatar Driver</h1>

          <AvatarDriver
            name="Noel Gallagher"
            image="https://picsum.photos/50"
            licensePlate="B 123456"
          />
        </div>
      </div>

      <div>
        <h1 className="mb-2 text-xl font-bold">Badge Status Pesanan</h1>

        <div className="flex flex-row flex-wrap gap-4">
          {[
            {
              icon: "/icons/info16.svg",

              label: "Menunggu Konfirmasi",

              variant: "primary",
            },

            {
              label: "Pesanan Terkonfirmasi",

              variant: "primary",
            },

            {
              label: "Armada Dijadwalkan",

              variant: "primary",
            },

            {
              label: "Proses Muat",

              variant: "primary",
            },

            {
              label: "Proses Bongkar",

              variant: "primary",
            },

            {
              label: "Dokumen Sedang Disiapkan",

              variant: "primary",
            },

            {
              label: "Proses Pengiriman Dokumen",

              variant: "primary",
            },

            {
              icon: "/icons/warning24.svg",

              label: "Perlu Respon Perubahan",

              variant: "warning",
            },

            {
              icon: "/icons/warning24.svg",

              label: "Perlu Konfirmasi Siap",

              variant: "error",
            },

            {
              icon: "/icons/warning24.svg",

              label: "Perlu Assign Armada",

              variant: "warning",
            },

            {
              label: "Selesai",

              variant: "success",
            },

            {
              label: "Dibatalkan Shipper",

              variant: "error",
            },

            {
              label: "Dibatalkan Transporter",

              variant: "error",
            },

            {
              label: "Dibatalkan Sistem",

              variant: "error",
            },

            {
              label: "Proses Muat",

              variant: "primary",

              className: "w-fit",
            },
          ].map((item, index) => (
            <BadgeStatusPesanan
              key={item.label + index}
              variant={item.variant}
              icon={{
                iconLeft: item.icon,
              }}
              className={item?.className}
            >
              <p>{item.label}</p>
            </BadgeStatusPesanan>
          ))}
        </div>
      </div>
    </div>
  );
};

const ExampleBanner = () => {
  const banners = [
    {
      id: 1,

      imageUrl: "/img/truck-banner.png",

      altText: "Promo Muatrans",

      linkUrl: "/promo/1",
    },

    {
      id: 2,

      imageUrl: "/img/truck-banner2.png",

      altText: "Layanan Pengiriman",

      linkUrl: "/services",
    },

    {
      id: 3,

      imageUrl: "/img/truck-banner3.png",

      altText: "Download Aplikasi",

      linkUrl: "/download",
    },
  ];

  return (
    <div>
      <h1 className="mb-2 text-center text-xl font-bold">Banner Carousel</h1>

      <BannerCarousel banners={banners} />
    </div>
  );
};

const BreadcrumbCardStepper = () => {
  const { t } = useTranslation();

  const breadcrumbItems = [
    { name: t("labelDashboard"), href: "/dashboard" },

    { name: t("daftarEtalase"), href: "/daftaretalase" },

    { name: t("ubahEtalase") },
  ];

  return (
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
      <div>
        <h1 className="mb-2 text-xl font-bold">Breadcrumb</h1>

        <BreadCrumb data={breadcrumbItems} />

        <h1 className="mb-2 mt-4 text-xl font-bold">Page Title</h1>

        <PageTitle>Contoh Judul Halaman</PageTitle>

        <h1 className="mb-2 mt-4 text-xl font-bold">Stepper</h1>

        <StepperContainer activeIndex={0} totalStep={6}>
          {[
            {
              label: "Pesanan Terkonfirmasi",

              status: "CONFIRMED",

              icon: "/icons/stepper/stepper-scheduled.svg",
            },

            {
              label: "Proses Muat",

              status: "LOADING",

              icon: "/icons/stepper/stepper-box.svg",
            },

            {
              label: "Proses Bongkar",

              status: "UNLOADING",

              icon: "/icons/stepper/stepper-box-opened.svg",
            },

            {
              label: "Selesai",

              status: "COMPLETED",

              icon: "/icons/stepper/stepper-completed.svg",
            },
          ].map((step, index) => (
            <StepperItemResponsive
              key={step.label}
              status={step?.status}
              icon={step.icon}
              index={index}
            />
          ))}
        </StepperContainer>
      </div>

      <div>
        <h1 className="mb-2 text-xl font-bold">Card Example</h1>

        <Card className="w-[400px]">
          <CardHeader>
            <h2 className="text-lg font-semibold">Card Title</h2>
          </CardHeader>

          <CardContent>
            <p className="text-sm text-neutral-600">
              This is an example of card content. You can put any content here.
            </p>

            <div className="mt-4 flex gap-4">
              <ListContent
                icon="/icons/location.svg"
                title="Location"
                value="Jakarta, Indonesia"
              />

              <ListContent
                icon="/icons/calendar16.svg"
                title="Date"
                value="24 March 2024"
              />
            </div>
          </CardContent>

          <CardFooter>
            <div className="flex justify-end gap-2">
              <Button variant="muattrans-primary-secondary">Cancel</Button>

              <Button variant="muattrans-primary">Submit</Button>
            </div>
          </CardFooter>
        </Card>
      </div>
    </div>
  );
};

const ButtonBottomsheetTooltipForm = () => {
  const [courierStatus, setCourierStatus] = useState({
    ambilLangsung: false,

    kurirToko: false,

    gojekInstant: true,

    grabInstant: true,

    jtRegular: false,

    jneRegular: false,

    sicepat: false,

    anteraja: false,

    posIndonesia: false,

    jtCargo: false,

    jneTrucking: false,

    wahana: false,
  });

  const toggleCourier = (courierName) => {
    setCourierStatus((prev) => ({
      ...prev,

      [courierName]: !prev[courierName],
    }));
  };

  const [batalkanModal, setBatalkanModal] = useState(false);

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="mb-2 text-xl font-bold">Buttons</h1>

        <div className="flex flex-wrap items-center gap-2">
          <Button variant="muattrans-primary">Primary</Button>

          <Button variant="muattrans-primary-secondary">
            Primary Secondary
          </Button>

          <Button variant="muattrans-error">Error</Button>

          <Button variant="muattrans-error-secondary">Error Secondary</Button>

          <Button variant="muattrans-warning">Warning</Button>

          <Button
            variant="muattrans-primary"
            onClick={() => toast.success("Toast Success")}
          >
            Toast Success
          </Button>

          <Button
            variant="muattrans-error"
            onClick={() => toast.error("Toast Error")}
          >
            Toast Error
          </Button>

          <div>
            <Toggle
              onClick={() => toggleCourier("ambilLangsung")}
              value={courierStatus.ambilLangsung}
            />
          </div>
        </div>
      </div>

      <div className="flex flex-wrap gap-4">
        <div>
          <h1 className="mb-2 text-xl font-bold">Modal</h1>

          <div className="flex flex-wrap items-center gap-2">
            <Modal closeOnOutsideClick>
              <ModalTrigger>
                <Button variant="muatparts-primary">Open Modal</Button>
              </ModalTrigger>

              <ModalContent className="w-modal-big">
                <ModalHeader size="big" />

                <div className="px-6 py-9">
                  <div className="flex w-[406px] max-w-[510px] flex-col items-center justify-center gap-6">
                    {/* Judul Modal */}

                    <h2 className="w-full text-center text-base font-bold leading-[19.2px] text-neutral-900">
                      Informasi
                    </h2>

                    {/* Box Peringatan */}

                    <div className="flex w-full flex-row items-center gap-2.5 rounded-md bg-warning-100 p-6">
                      <div className="flex items-center">
                        <IconComponent
                          src="/icons/warning24.svg"
                          height={24}
                          width={24}
                          className="text-[#FF7A00]"
                        />
                      </div>

                      <p className="text-xs font-medium leading-[14.4px] text-neutral-900">
                        Jika ada kendala pada persiapan atau perjalanan ke
                        lokasi muat, pengiriman mungkin tidak bisa dilanjutkan.
                        Kami akan tetap berusaha memberikan solusi terbaik.
                      </p>
                    </div>

                    {/* Text Konfirmasi */}

                    <p className="w-full text-center text-sm font-medium leading-[16.8px] text-neutral-900">
                      Apakah kamu yakin data yang kamu isi sudah benar? <br />
                      Pastikan semua informasi telah diperiksa sebelum melanjutkan.
                    </p>

                    {/* Text Syarat dan Ketentuan */}

                    <p className="w-[320px] text-center text-xs font-medium leading-[14.4px] text-neutral-900">
                      *Dengan memesan jasa angkut ini, kamu telah menyetujui{" "}
                      <Link href="/syarat-ketentuan">
                        <span className="text-primary-700 underline">
                          Syarat dan Ketentuan Muatrans
                        </span>
                      </Link>
                    </p>

                    {/* Container Tombol */}

                    <div className="flex flex-row justify-center gap-2">
                      <Button
                        variant="muatparts-primary-secondary"
                        className="h-8 min-w-[132px]"
                        type="muatparts"
                      >
                        Kembali
                      </Button>

                      <Button
                        variant="muatparts-primary"
                        className="h-8 min-w-[151px]"
                        type="muatparts"
                      >
                        Pesan Sekarang
                      </Button>
                    </div>
                  </div>
                </div>
              </ModalContent>
            </Modal>

            <div>
              <Button
                variant="muatparts-error-secondary"
                onClick={() => setBatalkanModal(true)}
              >
                Batalkan Modal
              </Button>

              {/* <BatalkanModal

                open={batalkanModal}

                onOpenChange={setBatalkanModal}

                onConfirm={() => setBatalkanModal(false)}

              /> */}
            </div>
          </div>
        </div>

        <div>
          <h1 className="mb-2 text-xl font-bold">Bottomsheet</h1>

          <BottomSheet>
            <BottomSheetTrigger>
              <Button variant="muatparts-primary">Bottomsheet</Button>
            </BottomSheetTrigger>

            <BottomSheetContent>
              <BottomSheetHeader>
                <BottomSheetClose />

                <BottomSheetTitle>Bagikan Produk</BottomSheetTitle>
              </BottomSheetHeader>

              <div className="divide-y px-4">
                <button className="w-full px-6 py-4 text-left">
                  Ringkasan Status Pesanan
                </button>

                <button className="w-full px-6 py-4 text-left">
                  Detail Pengiriman Dokumen
                </button>

                <button className="w-full px-6 py-4 text-left">
                  Detail Pembayaran
                </button>

                <button className="w-full px-6 py-4 text-left">
                  Ubah Pesanan
                </button>

                <button className="w-full px-6 py-4 text-left">
                  Unduh Dokumen Delivery Order (DO)
                </button>
              </div>
            </BottomSheetContent>
          </BottomSheet>
        </div>

        <div>
          <h1 className="mb-2 text-xl font-bold">
            FormContainer, FormLabel, InfoBottomsheet
          </h1>

          <FormContainer>
            <FormLabel
              required
              tooltip={
                <InfoBottomsheet title="Info Bottomsheet">
                  <span>
                    Jika kamu mencentang opsi ini kamu akan dikenakan PPh 23
                    terhadap pembayaran sewa jasa angkut yang kamu lakukan
                  </span>
                </InfoBottomsheet>
              }
            >
              Info Bottomsheet
            </FormLabel>
          </FormContainer>
        </div>

        <div>
          <h1 className="mb-2 text-xl font-bold">
            FormContainer, FormLabel, InfoBottomsheet
          </h1>

          <FormContainer>
            <FormLabel
              required
              tooltip={
                <InfoTooltip>
                  <p>
                    Jika kamu mencentang opsi ini kamu akan dikenakan PPh 23
                    terhadap pembayaran sewa jasa angkut yang kamu lakukan
                  </p>
                </InfoTooltip>
              }
            >
              Info Tooltip
            </FormLabel>
          </FormContainer>
        </div>
      </div>
    </div>
  );
};

const ExampleTimeline = () => {
  return (
    <div>
      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        <div>
          <h1 className="mb-2 text-xl font-bold">
            List Timeline Muat Bongkar (Number)
          </h1>

          <TimelineContainer>
            {dataMuatBongkar.map((item, index) => (
              <NewTimelineItem
                key={index}
                variant="number-muat"
                index={index}
                activeIndex={0}
                title={item.title}
              />
            ))}
          </TimelineContainer>
        </div>

        <div>
          <h1 className="mb-2 text-xl font-bold">
            List Timeline Bongkar (Number)
          </h1>

          <TimelineContainer>
            {dataMuatBongkar.map((item, index) => (
              <NewTimelineItem
                key={index}
                variant="number-bongkar"
                index={index}
                activeIndex={0}
                title={item.title}
              />
            ))}
          </TimelineContainer>
        </div>

        <div>
          <h1 className="mb-2 text-xl font-bold">
            List Timeline Bongkar Muat (Bullet)
          </h1>

          <TimelineContainer>
            {dataMuatBongkar.map((item, index) => (
              <NewTimelineItem
                key={index}
                variant="bullet"
                index={index}
                activeIndex={2}
                title={item.title}
              />
            ))}
          </TimelineContainer>
        </div>

        <div className="grid gap-4">
          <div className="max-w-[400px]">
            <h1 className="mb-2 text-xl font-bold">
              Timeline Bongkar Muat Collapsed
            </h1>

            <TimelineContainer>
              {dataCollapsed.map((item, index) => (
                <NewTimelineItem
                  key={index}
                  variant="bullet"
                  index={index}
                  activeIndex={0}
                  title={item.title}
                  buttonDetail={
                    <ButtonMini
                      onClick={() => alert("Lihat Bukti Muat Barang & POD")}
                    >
                      Lihat Bukti Muat Barang & POD
                    </ButtonMini>
                  }
                />
              ))}
            </TimelineContainer>
          </div>

          <div className="max-w-[400px]">
            <h1 className="mb-2 text-xl font-bold">Detail Status Driver</h1>

            <TimelineContainer>
              {dataCollapsedWithDate.map((item, index) => (
                <NewTimelineItem
                  key={index}
                  variant="bullet-driver-status"
                  index={index}
                  activeIndex={0}
                  title={item.title}
                  buttonDetail={
                    <ButtonMini
                      onClick={() => alert("Lihat Bukti Muat Barang & POD")}
                    >
                      Lihat Bukti Muat Barang & POD
                    </ButtonMini>
                  }
                />
              ))}
            </TimelineContainer>
          </div>
        </div>
      </div>

      <ExampleTimelineField />
    </div>
  );
};

const ExampleTimelineField = () => {
  const [muatValues, setMuatValues] = useState([]);

  const handleAddMuatLocation = () => {
    setMuatValues([
      ...muatValues,

      fakeAddress[Math.floor(Math.random() * fakeAddress.length)],
    ]);
  };

  const handleDeleteMuatLocation = (index) => {
    setMuatValues(muatValues.filter((_, i) => i !== index));
  };

  const [bongkarValues, setBongkarValues] = useState([]);

  const handleAddBongkarLocation = () => {
    setBongkarValues([
      ...bongkarValues,

      fakeAddress[Math.floor(Math.random() * fakeAddress.length)],
    ]);
  };

  const handleDeleteBongkarLocation = (index) => {
    setBongkarValues(bongkarValues.filter((_, i) => i !== index));
  };

  return (
    <div className="mt-4 grid grid-cols-1 gap-4 md:grid-cols-2">
      <div className="max-w-[400px]">
        <h1 className="mb-2 text-xl font-bold">Timeline Field Muat</h1>

        <TimelineField.Root
          variant="muat"
          values={muatValues.map((value) => ({ name: value.address }))}
          onAddLocation={handleAddMuatLocation}
          onEditLocation={(index) =>
            alert(`Handle edit location in index: ${index}`)
          }
        >
          {muatValues.map((_, index) => (
            <TimelineField.Item
              index={index}
              key={index}
              buttonRemove={
                <TimelineField.RemoveButton
                  onClick={() => handleDeleteMuatLocation(index)}
                />
              }
            />
          ))}

          <TimelineField.AddButton />
        </TimelineField.Root>
      </div>

      <div className="max-w-[400px]">
        <h1 className="mb-2 text-xl font-bold">Timeline Field Bongkar</h1>

        <TimelineField.Root
          variant="bongkar"
          values={bongkarValues.map((value) => ({ name: value.address }))}
          onAddLocation={handleAddBongkarLocation}
        >
          {bongkarValues.map((_, index) => (
            <TimelineField.Item
              index={index}
              key={index}
              buttonRemove={
                <TimelineField.RemoveButton
                  onClick={() => handleDeleteBongkarLocation(index)}
                />
              }
            />
          ))}

          <TimelineField.AddButton />
        </TimelineField.Root>
      </div>
    </div>
  );
};

const ExampleLightbox = () => {
  const images = [
    "https://picsum.photos/400/300?random=1",

    "https://picsum.photos/400/300?random=2",

    "https://picsum.photos/400/300?random=3",

    "https://picsum.photos/400/300?random=4",
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-2">
      <div>
        <h1 className="mb-2 text-xl font-bold">Lightbox (Single Image)</h1>

        <LightboxProvider image={images[0]} title="Jenis Carrier">
          <LightboxPreview
            image={images[0]}
            alt="Jenis Carrier"
            className="size-[100px] overflow-hidden rounded-md object-cover"
          />
        </LightboxProvider>
      </div>

      <div>
        <h1 className="mb-2 text-xl font-bold">Lightbox (Multiple Images)</h1>

        <LightboxProvider images={images} title="Bukti Muat Barang di Lokasi 2">
          <div className="flex flex-wrap gap-2">
            {images.map((image, index) => (
              <LightboxPreview
                key={index}
                image={image}
                index={index}
                className="size-[100px] overflow-hidden rounded-md object-cover"
                alt={`Bukti Muat Barang di Lokasi 2, Foto ke-${index + 1}`}
              />
            ))}
          </div>
        </LightboxProvider>
      </div>

      {/* implement ImagesPreview here */}
    </div>
  );
};

// Demo Component

const ExampleDropdownJasaPengiriman = () => {
  const [selectedExpedition, setSelectedExpedition] = useState(null);

  const jasaPengirimanOptions = [
    {
      groupName: "Reguler",

      expeditions: [
        {
          id: "2e395ac7-9a91-4884-8ee2-e3a9a2d5cc78",

          courierName: "J&T Express",

          libraryID: 1,

          rateID: 57,

          minEstimatedDay: 2,

          maxEstimatedDay: 3,

          originAreaId: 30052,

          destinationAreaId: 30169,

          weight: 1,

          originalCost: 6000,

          originalInsurance: 25,

          mustUseInsurance: false,
        },

        {
          id: "a0fe91ff-2375-44d4-bd22-a52d5d290c17",

          courierName: "Ninja Xpress",

          libraryID: 1,

          rateID: 228,

          minEstimatedDay: 3,

          maxEstimatedDay: 5,

          originAreaId: 30052,

          destinationAreaId: 30169,

          weight: 1,

          originalCost: 6000,

          originalInsurance: 1000,

          mustUseInsurance: false,
        },

        {
          id: "f229affd-453b-4a6f-8151-7943322e76f9",

          courierName: "SAPX Express",

          libraryID: 1,

          rateID: 349,

          minEstimatedDay: 1,

          maxEstimatedDay: 2,

          originAreaId: 30052,

          destinationAreaId: 30169,

          weight: 1,

          originalCost: 9000,

          originalInsurance: 2030,

          mustUseInsurance: false,
        },

        {
          id: "3fdca0d2-1ec2-4b85-80a7-d0326a4ae759",

          courierName: "SiCepat",

          libraryID: 1,

          rateID: 58,

          minEstimatedDay: 1,

          maxEstimatedDay: 2,

          originAreaId: 30052,

          destinationAreaId: 30169,

          weight: 1,

          originalCost: 7000,

          originalInsurance: 25,

          mustUseInsurance: false,
        },

        {
          id: "f390c703-ce44-458a-8909-ce41a2369a42",

          courierName: "SiCepat (BEST)",

          libraryID: 1,

          rateID: 59,

          minEstimatedDay: 1,

          maxEstimatedDay: 1,

          originAreaId: 30052,

          destinationAreaId: 30169,

          weight: 1,

          originalCost: 11000,

          originalInsurance: 25,

          mustUseInsurance: false,
        },
      ],
    },

    {
      groupName: "Kargo",

      expeditions: [
        {
          id: "d2a44f7b-b4a8-44e8-ad0c-0900ff737ca7",

          courierName: "JNE Trucking (JTR)",

          libraryID: 1,

          rateID: 312,

          minEstimatedDay: 3,

          maxEstimatedDay: 4,

          originAreaId: 30052,

          destinationAreaId: 30169,

          weight: 1,

          originalCost: 40000,

          originalInsurance: 25,

          mustUseInsurance: false,
        },
      ],
    },

    {
      groupName: "Instan",

      expeditions: [
        {
          id: "b1900bbf-2127-407d-9971-914333f0c358",

          courierName: "Gosend",

          libraryID: 1,

          rateID: 329,

          minEstimatedDay: 0,

          maxEstimatedDay: 0,

          originAreaId: 30052,

          destinationAreaId: 30169,

          weight: 1,

          originalCost: 23500,

          originalInsurance: 0,

          mustUseInsurance: false,
        },

        {
          id: "1d302d7f-6ec5-46ba-a3c6-0740af86d773",

          courierName: "Grab Express",

          libraryID: 1,

          rateID: 340,

          minEstimatedDay: 0,

          maxEstimatedDay: 0,

          originAreaId: 30052,

          destinationAreaId: 30169,

          weight: 1,

          originalCost: 50000,

          originalInsurance: 0,

          mustUseInsurance: false,
        },
      ],
    },
  ];

  const handleExpeditionChange = (data) => {
    setSelectedExpedition(data);

    alert("Expedition data:", data);
  };

  return (
    <div className="min-h-screen p-8">
      <div className="mx-auto max-w-md space-y-6">
        <div>
          <h2 className="mb-4 text-lg font-semibold">
            Expedition Dropdown Component
          </h2>

          <div className="space-y-4">
            <div>
              <label className="mb-2 block text-sm font-medium text-gray-700">
                Choose Shipping Method
              </label>

              <DropdownJasaPengiriman
                shippingOptions={jasaPengirimanOptions}
                value={selectedExpedition}
                onChange={handleExpeditionChange}
                placeholder="Pilih Ekspedisi"
                insuranceText="Pakai Asuransi Pengiriman"
              />
            </div>

            {selectedExpedition && (
              <div className="rounded-md bg-blue-50 p-4">
                <p className="mb-2 text-sm">
                  <strong>Selected Expedition:</strong>{" "}
                  {selectedExpedition.expedition?.courierName} -{" "}
                  {selectedExpedition.expedition?.originalCost}
                </p>

                <p className="mb-2 text-sm">
                  <strong>Insurance:</strong>{" "}
                  {selectedExpedition.hasInsurance
                    ? `Yes (${selectedExpedition.insurancePrice})`
                    : "No"}
                </p>

                <p className="text-sm">
                  <strong>Total Cost:</strong>{" "}
                  {selectedExpedition.hasInsurance
                    ? selectedExpedition.expedition?.originalCost +
                      selectedExpedition.insurancePrice
                    : selectedExpedition.expedition?.originalCost}
                </p>
              </div>
            )}

            <div>
              <label className="mb-2 block text-sm font-medium text-gray-700">
                Disabled State
              </label>

              <DropdownJasaPengiriman
                disabled={true}
                placeholder="Disabled dropdown"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

const ExampleInput = () => {
  const [selectValue, setSelectValue] = useState("");

  const [tags, setTags] = useState([]);

  const [tagsError, setTagsError] = useState("");

  const [expandableValue, setExpandableValue] = useState("");

  const [fileValue, setFileValue] = useState(null);

  const [panjang, setPanjang] = useState("");

  const [lebar, setLebar] = useState("");

  const [tinggi, setTinggi] = useState("");

  const [numberValue, setNumberValue] = useState(0);

  const [searchValue, setSearchValue] = useState("");

  const [selectedSearch, setSelectedSearch] = useState(null);

  const [quantityValue, setQuantityValue] = useState(1);

  const [shippingMethod, setShippingMethod] = useState("");

  const [sortValue, setSortValue] = useState("newest");

  const [textAreaValue, setTextAreaValue] = useState("");

  const [feedbackValue, setFeedbackValue] = useState("");

  const [addressValue, setAddressValue] = useState("");

  const [notesValue, setNotesValue] = useState("");

  return (
    <div className="flex flex-wrap items-start gap-8">
      <div>
        <h1 className="mb-2 text-xl font-bold">Checkbox</h1>

        <div className="flex flex-col gap-4">
          <Checkbox
            label="Default Checkbox"
            onChange={({ checked, value }) =>
              alert("Checkbox changed:", { checked, value })
            }
          />

          <Checkbox
            label="Checked by default"
            checked={true}
            onChange={({ checked, value }) =>
              alert("Checkbox changed:", { checked, value })
            }
          />

          <Checkbox
            label="Disabled Checkbox"
            disabled={true}
            onChange={({ checked, value }) =>
              alert("Checkbox changed:", { checked, value })
            }
          />

          <Checkbox
            label="Disabled Checked"
            disabled={true}
            checked={true}
            onChange={({ checked, value }) =>
              alert("Checkbox changed:", { checked, value })
            }
          />

          <Checkbox
            value="custom-value"
            onChange={({ checked, value }) =>
              alert("Checkbox changed:", { checked, value })
            }
          >
            <span className="text-primary-700">Custom styled label</span>
          </Checkbox>
        </div>
      </div>

      <div className="w-[150px]">
        <h1 className="mb-2 text-xl font-bold">Select</h1>

        <Select
          placeholder="Pilih Satuan"
          options={[
            {
              label: "kg",

              value: "kg",
            },

            {
              label: "Liter",

              value: "liter",
            },

            {
              label: "Ton",

              value: "ton",
            },
          ]}
          value={selectValue}
          onChange={setSelectValue}
        />
      </div>

      <div className="w-[400px]">
        <h1 className="mb-2 text-xl font-bold">Tag Input</h1>

        <TagInput
          tags={tags}
          onTagsChange={setTags}
          placeholder="Masukkan No. Delivery Order (DO)"
          onTagsDuplicate={(duplicateTag) =>
            setTagsError(`Tag ${duplicateTag} sudah ada`)
          }
          errorMessage={tagsError}
        />
      </div>

      <div>
        <h1 className="mb-2 text-xl font-bold">Image Uploader with Cropper</h1>

        <div className="flex flex-col gap-4">
          <ImageUploaderWeb
            getImage={(image) => alert("Image uploaded:", image)}
            uploadText="Upload Image"
            errorText="Upload Again"
            maxSize={5}
            isCircle={true}
            onUpload={(image) => alert("Image uploaded:", image)}
            onError={(error) => alert("Upload error:", error)}
            cropperTitle="Crop Image"
            onFinishCrop={(file) => alert("Cropped file:", file)}
            acceptedFormats={[".jpg", ".jpeg", ".png"]}
          />
        </div>
      </div>

      <div className="w-[400px]">
        <h1 className="mb-2 text-xl font-bold">Expandable Text Area</h1>

        <MyTextArea
          value={expandableValue}
          onChange={(e) => setExpandableValue(e.target.value)}
          placeholder="Type something here..."
        />

        <div className="mt-2 text-xs text-neutral-500">
          {expandableValue.length} characters
        </div>
      </div>

      <div className="w-[400px]">
        <h1 className="mb-2 text-xl font-bold">File Upload</h1>

        <FileUpload
          value={fileValue}
          onSuccess={(file) => {
            setFileValue(file);

            alert("File uploaded:", file);
          }}
          onError={(err) => {
            console.error("File upload error:", err);
          }}
          maxSize={5}
          acceptedFormats={[".jpg", ".jpeg", ".png", ".pdf"]}
        />
      </div>

      <div className="w-[400px]">
        <h1 className="mb-2 text-xl font-bold">Dimension Input</h1>

        <DimensionInput
          manual={{
            panjang: { value: panjang, setValue: setPanjang },

            lebar: { value: lebar, setValue: setLebar },

            tinggi: { value: tinggi, setValue: setTinggi },
          }}
        />

        <div className="mt-2 text-xs text-neutral-500">
          Panjang: {panjang || 0} cm, Lebar: {lebar || 0} cm, Tinggi:{" "}
          {tinggi || 0} cm
        </div>
      </div>

      <div className="w-[400px]">
        <h1 className="mb-2 text-xl font-bold">Number Input</h1>

        <NumberInput
          value={numberValue}
          onValueChange={setNumberValue}
          min={0}
          max={100}
          stepper={1}
          placeholder="Enter a number"
          suffix=" pcs"
          hideStepper={false}
        />

        <div className="mt-2 text-xs text-neutral-500">
          Value: {numberValue || 0}
        </div>
      </div>

      <div className="w-[400px]">
        <h1 className="mb-2 text-xl font-bold">Input Search</h1>

        <InputSearch
          options={[
            { label: "Apple", value: "apple" },

            { label: "Banana", value: "banana" },

            { label: "Orange", value: "orange" },

            { label: "Mango", value: "mango" },
          ]}
          getOptionLabel={(option) => option.label}
          onSelectValue={(option) => setSelectedSearch(option)}
          searchValue={searchValue}
          setSearchValue={setSearchValue}
          placeholder="Search fruits..."
        />

        <div className="mt-2 text-xs text-neutral-500">
          Selected: {selectedSearch ? selectedSearch.label : "None"}
        </div>
      </div>

      <div className="w-[200px]">
        <h1 className="mb-2 text-xl font-bold">Quantity Input</h1>

        <QuantityInput
          maxStock={10}
          minQuantity={1}
          initialValue={quantityValue}
          onChange={setQuantityValue}
        />

        <div className="mt-2 text-xs text-neutral-500">
          Value: {quantityValue}
        </div>
      </div>

      <div className="w-[300px]">
        <h1 className="mb-2 text-xl font-bold">Radio Button Example</h1>

        <div className="flex flex-col gap-4">
          <RadioButton
            name="shipping"
            label="Regular Shipping"
            value="regular"
            checked={shippingMethod === "regular"}
            onClick={(data) => setShippingMethod(data.value)}
          />

          <RadioButton
            name="shipping"
            label="Express Shipping"
            value="express"
            checked={shippingMethod === "express"}
            onClick={(data) => setShippingMethod(data.value)}
          />

          <RadioButton
            name="shipping"
            label="Priority Shipping"
            value="priority"
            checked={shippingMethod === "priority"}
            onClick={(data) => setShippingMethod(data.value)}
            disabled
          />
        </div>

        <div className="mt-2 text-xs text-neutral-500">
          Selected: {shippingMethod || "None"}
        </div>
      </div>

      <div>
        <h1 className="mb-2 text-xl font-bold">Sorting Dropdown Example</h1>

        <div className="flex flex-col gap-4">
          <div>
            <h2 className="mb-2 text-sm font-medium">Default Sorting</h2>

            <SortingDropdown
              options={[
                { label: "Terbaru", value: "newest" },

                { label: "Terlama", value: "oldest" },

                { label: "Harga Tertinggi", value: "price_high" },

                { label: "Harga Terendah", value: "price_low" },
              ]}
              value={sortValue}
              onChange={setSortValue}
            />

            <div className="mt-2 text-xs text-neutral-500">
              Selected: {sortValue}
            </div>
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">Disabled State</h2>

            <SortingDropdown
              options={[
                { label: "Terbaru", value: "newest" },

                { label: "Terlama", value: "oldest" },
              ]}
              value="newest"
              onChange={() => {}}
              disabled
            />
          </div>
        </div>
      </div>

      <div>
        <h1 className="mb-2 text-xl font-bold">Text Area Example</h1>

        <div className="flex flex-col gap-8">
          <div>
            <h2 className="mb-2 text-sm font-medium">Default Text Area</h2>

            <TextArea
              placeholder="Enter your message here..."
              value={textAreaValue}
              onChange={(e) => setTextAreaValue(e.target.value)}
              maxLength={200}
              hasCharCount
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">With Supportive Text</h2>

            <TextArea
              placeholder="Enter your feedback..."
              value={feedbackValue}
              onChange={(e) => setFeedbackValue(e.target.value)}
              supportiveText={{
                title: "Feedback",

                desc: "Please provide detailed feedback",
              }}
              maxLength={500}
              hasCharCount
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">Error State</h2>

            <TextArea
              placeholder="Enter your address..."
              value={addressValue}
              onChange={(e) => setAddressValue(e.target.value)}
              status="error"
              supportiveText={{
                title: "Address",

                desc: "Please enter a valid address",
              }}
              maxLength={300}
              hasCharCount
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">Success State</h2>

            <TextArea
              placeholder="Enter your notes..."
              value={notesValue}
              onChange={(e) => setNotesValue(e.target.value)}
              status="success"
              supportiveText={{
                title: "Notes",

                desc: "Notes saved successfully",
              }}
              maxLength={150}
              hasCharCount
            />
          </div>

          <div>
            <h2 className="mb-2 text-sm font-medium">Disabled State</h2>

            <TextArea
              placeholder="This textarea is disabled..."
              value="This is a disabled textarea"
              disabled
              supportiveText={{
                title: "Disabled",

                desc: "This field cannot be edited",
              }}
            />
          </div>
        </div>
      </div>

      <ExampleDropdownJasaPengiriman />
    </div>
  );
};

// Example usage component

const MapExample = () => {
  // Example waypoints for connecting locations (optional - can be empty)

  const exampleWaypoints = [
    { lat: -7.2504, lng: 112.7344 }, // Lokasi Bongkar 1

    { lat: -7.2601, lng: 112.7589 }, // Lokasi Muat 2

    { lat: -7.2445, lng: 112.7723 }, // Lokasi Muat 1
  ];

  // Separate truck waypoints from backend - completely independent path

  const truckWaypoints = [
    { lat: -7.248, lng: 112.73 }, // Truck starting point

    { lat: -7.2495, lng: 112.735 }, // Truck waypoint 1

    { lat: -7.251, lng: 112.742 }, // Truck waypoint 2

    { lat: -7.253, lng: 112.748 }, // Truck waypoint 3

    { lat: -7.256, lng: 112.754 }, // Truck waypoint 4

    { lat: -7.258, lng: 112.76 }, // Truck waypoint 5

    { lat: -7.259, lng: 112.765 }, // Truck waypoint 6

    { lat: -7.257, lng: 112.77 }, // Truck waypoint 7

    { lat: -7.252, lng: 112.775 }, // Truck waypoint 8

    { lat: -7.246, lng: 112.772 }, // Truck current position (end)
  ];

  const exampleMarkers = useMemo(
    () => [
      {
        id: "muat1",

        position: { lat: -7.2445, lng: 112.7723 },

        title: "Lokasi Muat 1",

        icon: "/icons/marker-lokasi-muat.svg",
      },

      {
        id: "muat2",

        position: { lat: -7.2601, lng: 112.7589 },

        title: "Lokasi Muat 2",

        icon: "/icons/marker-lokasi-muat.svg",
      },

      {
        id: "bongkar1",

        position: { lat: -7.2504, lng: 112.7344 },

        title: "Lokasi Bongkar 1",

        icon: "/icons/marker-lokasi-bongkar.svg",
      },
    ],

    []
  );

  const [mapCoordinates, setMapCoordinates] = useState({
    latitude: -7.2575,

    longitude: 112.7521,
  });

  return (
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
      <div>
        <h1 className="mb-4 text-2xl font-bold">MapContainer Example</h1>

        <MapContainer
          coordinates={mapCoordinates}
          onPositionChange={setMapCoordinates}
          textLabel={`Lat: ${mapCoordinates.latitude.toFixed(
            5
          )}, Lng: ${mapCoordinates.longitude.toFixed(5)}`}
          className="h-[600px] w-[600px]"
        />

        <div className="mt-2 text-xs text-neutral-500">
          Current Position: Lat {mapCoordinates.latitude.toFixed(5)}, Lng{" "}
          {mapCoordinates.longitude.toFixed(5)}
        </div>
      </div>

      <div>
        <h1 className="mb-4 text-2xl font-bold">Truck Route Map Component</h1>

        <div className="mb-6">
          <h2 className="mb-2 text-lg font-semibold">Example Usage:</h2>

          <MapWithPath
            apiKey="AIzaSyDw_9D9-4zTechHn1wMEILZqiBv51Q7jHU"
            waypoints={exampleWaypoints} // Location connection waypoints
            truckWaypoints={truckWaypoints} // Separate truck path from backend
            markers={exampleMarkers}
            center={{ lat: -7.2575, lng: 112.7521 }}
            zoom={13}
            pathOptions={{
              strokeColor: "#FF6B35", // Orange for location connections

              strokeOpacity: 1,

              strokeWeight: 4,
            }}
            truckPathOptions={{
              strokeColor: "#4CAF50", // Green for truck path

              strokeOpacity: 0.8,

              strokeWeight: 3,
            }}
            mapContainerStyle={{ width: "100%", height: "500px" }}
            showTruck={true}
            truckIcon="/icons/marker-truck.svg"
          />
        </div>

        <div className="rounded-lg bg-gray-50 p-4">
          <h3 className="mb-2 font-semibold">Component Props:</h3>

          <ul className="space-y-1 text-sm text-gray-700">
            <li>
              <strong>apiKey</strong>: Your Google Maps API key (required)
            </li>

            <li>
              <strong>waypoints</strong>: Array of {"{ lat, lng }"} objects for
              location connections (optional)
            </li>

            <li>
              <strong>truckWaypoints</strong>: Array of {"{ lat, lng }"} objects
              for the truck&apos;s actual path from backend
            </li>

            <li>
              <strong>markers</strong>: Array of marker objects with position,
              title, icon, etc.
            </li>

            <li>
              <strong>center</strong>: Map center position
            </li>

            <li>
              <strong>zoom</strong>: Initial zoom level
            </li>

            <li>
              <strong>pathOptions</strong>: Styling options for location
              connection lines
            </li>

            <li>
              <strong>truckPathOptions</strong>: Styling options for truck route
              line
            </li>

            <li>
              <strong>mapContainerStyle</strong>: CSS styling for map container
            </li>

            <li>
              <strong>showTruck</strong>: Boolean to show/hide truck icon
              (default: true)
            </li>

            <li>
              <strong>truckIcon</strong>: Path to truck icon SVG file
            </li>
          </ul>
        </div>

        <div className="mt-4 rounded-lg bg-blue-50 p-4">
          <h3 className="mb-2 font-semibold text-blue-800">Truck Features:</h3>

          <ul className="space-y-1 text-sm text-blue-700">
            <li>
              • <strong>Independent Truck Path:</strong> Truck waypoints are
              completely separate from location markers
            </li>

            <li>
              • <strong>Backend Integration:</strong> truckWaypoints prop
              accepts raw GPS data from your backend
            </li>

            <li>
              • <strong>Dual Path Rendering:</strong> Shows both location
              connections (orange) and truck path (green)
            </li>

            <li>
              • <strong>Smart Truck Positioning:</strong> Truck icon positioned
              at the last waypoint
            </li>

            <li>
              • <strong>Automatic Rotation:</strong> Truck rotates based on
              direction of travel
            </li>

            <li>
              • <strong>Visual Differentiation:</strong> Different colors and
              styles for each path type
            </li>
          </ul>
        </div>
      </div>
    </div>
  );
};

// Example usage component

export const TabsExample = () => {
  const [activeTab, setActiveTab] = useState("ringkasan");

  return (
    <div className="mx-auto w-full max-w-md">
      {/* Basic Usage */}

      <Tabs defaultValue="account" className="w-[400px]">
        <TabsList>
          <TabsTrigger value="account">Account</TabsTrigger>

          <TabsTrigger value="password">Password</TabsTrigger>
        </TabsList>

        <TabsContent value="account">
          Make changes to your account here.
        </TabsContent>

        <TabsContent value="password">Change your password here.</TabsContent>
      </Tabs>

      {/* Design-based Usage (similar to your mockup) */}

      <div className="mt-8">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="w-full">
            <TabsTriggerWithSeparator value="ringkasan">
              Ringkasan
            </TabsTriggerWithSeparator>

            <TabsTriggerWithSeparator value="muatan">
              Muatan
            </TabsTriggerWithSeparator>

            <TabsTriggerWithSeparator value="detail-pic" showSeparator={false}>
              Detail PIC
            </TabsTriggerWithSeparator>
          </TabsList>

          <TabsContent value="ringkasan" className="p-4">
            <div className="space-y-4">
              <div>
                <h3 className="mb-2 text-sm font-semibold text-neutral-900">
                  Informasi Armada
                </h3>

                <div className="flex items-center gap-3">
                  <div className="flex h-16 w-16 items-center justify-center rounded border border-neutral-300 bg-neutral-50">
                    <span className="text-xs text-neutral-500">Truck</span>
                  </div>

                  <div>
                    <p className="text-sm font-semibold text-neutral-900">
                      Box - Colt Diesel Engkel
                    </p>

                    <p className="text-sm text-neutral-600">
                      Kebutuhan : 1 Unit
                    </p>
                  </div>
                </div>
              </div>

              <div>
                <h3 className="mb-2 text-sm font-semibold text-neutral-900">
                  Waktu Muat
                </h3>

                <p className="text-xs font-semibold text-neutral-900">
                  03 Okt 2024 18:00 WIB s/d 04 Okt 2024 08:00 WIB
                </p>
              </div>
            </div>
          </TabsContent>

          <TabsContent value="muatan" className="p-4">
            <div className="py-8 text-center">
              <p className="text-neutral-500">
                Informasi muatan akan ditampilkan di sini
              </p>
            </div>
          </TabsContent>

          <TabsContent value="detail-pic" className="p-4">
            <div className="py-8 text-center">
              <p className="text-neutral-500">
                Detail PIC akan ditampilkan di sini
              </p>
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
};
```

# Guidelines for Correctly Implementing Scrollable Elements and Lightbox Components

## Scrollable Element Implementation Guidelines

### 1. Analyze Container Constraints First

- Identify if the container has fixed dimensions (width/height) from design specs

- Note whether the container should be fully responsive or maintain fixed dimensions

- Check if scroll is needed on one axis (vertical/horizontal) or both

### 2. Establish a Clear Layout Hierarchy

- Divide the UI into fixed and scrollable regions before writing any code

- Explicitly identify which parts should scroll and which should remain fixed

- Use parent-child relationships to properly nest scrollable content

### 3. Fixed Height Container Pattern

```jsx
// Fixed height container with scrollable content

<div className="flex h-[460px] w-[472px] flex-col">
  {/* Fixed header - does not scroll */}

  <div className="px-6 pt-6">
    <h2>Fixed Header Content</h2>

    <div>Search Bar or Other Fixed Elements</div>
  </div>

  {/* Scrollable content area - will scroll independently */}

  <div className="flex-1 overflow-y-auto px-6 pb-6">
    {/* Content here will scroll */}

    <div>Scrollable Content</div>
  </div>
</div>
```

### 4. Key CSS Properties for Scrolling

- Always use `flex-1` or explicit height on the scrollable container to ensure it fills available space

- Always set the overflow property explicitly: `overflow-y-auto` for vertical, `overflow-x-auto` for horizontal

- Use appropriate padding inside the scrollable area, not just on the parent

- For non-touch devices, consider adding `pr-2` or `scrollbar-thin` for better scrollbar appearance

### 5. Testing Scroll Behavior

- Always ensure there's enough content to test scrolling (add extra items if needed)

- Check scroll behavior both with minimal content and with excessive content

- Verify that fixed elements remain in position when scrolling

## Lightbox Component Implementation Guidelines

### 1. Visual Indicators Requiring Lightbox

- **ALWAYS** implement Lightbox when an image has:

  - A magnifying glass/zoom icon overlay

  - A fullscreen icon

  - An expand icon in the corner

  - Any visual indicator suggesting the image can be enlarged

### 2. Standard Lightbox Implementation Pattern

```jsx



import { LightboxProvider, LightboxPreview } from "@/components/Lightbox/Lightbox";




// For single images:



<div className="relative h-[68px] w-[68px]">



  <LightboxProvider



    image="https://example.com/image.jpg"



    title="Image Title"



  >



    <LightboxPreview



      image="https://example.com/image.jpg"



      alt="Image description"



      className="h-full w-full object-cover"



    />



  </LightboxProvider>



</div>




// For multiple images:



<LightboxProvider



  images={[image1, image2, image3]}



  title="Gallery Title"



>



  <div className="flex gap-2">



    {images.map((image, index) => (



      <LightboxPreview



        key={index}



        image={image}



        index={index}



        className="h-[68px] w-[68px] object-cover"



        alt={`Image ${index + 1}`}



      />



    ))}



  </div>



</LightboxProvider>



```

### 3. Image Quality Considerations

- Use higher resolution images for lightbox viewing (at least 2x the display size)

- Maintain aspect ratio between thumbnails and full-size images

- Consider providing multiple image sizes for different devices

### 4. Systematic Checklist for Designs

Before finalizing any component with images:

1. ✓ Scan ALL images for zoom/expand icons

2. ✓ Check corner overlays on images that might indicate lightbox functionality

3. ✓ Review the design for image grids that might benefit from gallery lightbox

4. ✓ Ask if users would need to see detail in small images (product photos, documents, etc.)

## Combined Modal with Scrolling and Lightbox Example

```jsx
// Template for modal with scrollable content and lightbox images

const ModalWithScrollAndLightbox = () => {
  return (
    <Modal>
      <ModalTrigger>
        <Button>Open Modal</Button>
      </ModalTrigger>

      <ModalContent className="w-[472px]">
        {/* Fixed height container */}

        <div className="flex h-[460px] flex-col">
          {/* Fixed header section - won't scroll */}

          <div className="px-6 pt-6">
            <h2 className="text-center font-bold">Modal Title</h2>

            {/* Other fixed elements like search, filters, etc. */}
          </div>

          {/* Scrollable content section */}

          <div className="mt-4 flex-1 overflow-y-auto px-6 pb-6">
            {/* Repeating content items */}

            {items.map((item) => (
              <div key={item.id} className="border-b py-3">
                {/* Image with lightbox */}

                <div className="relative h-[68px] w-[68px]">
                  <LightboxProvider image={item.image} title={item.title}>
                    <LightboxPreview
                      image={item.image}
                      alt={item.title}
                      className="h-full w-full object-cover"
                    />
                  </LightboxProvider>
                </div>

                {/* Item content */}

                <div className="mt-2">
                  <h3>{item.title}</h3>

                  <p>{item.description}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </ModalContent>
    </Modal>
  );
};
```

## Critical Reminders

1. **ALWAYS** start with container constraints and layout hierarchy before writing any component code

2. **NEVER** implement scrolling without explicitly defining:

   - Which container should scroll

   - The height constraint (fixed or dynamic)

   - The overflow property

3. **ALWAYS** check for zoom/expand icons on ANY image in the design - these indicate lightbox functionality

4. When in doubt about scrolling behavior, use the fixed pattern:

   ```jsx
   {
     /* Parent with fixed height */
   }

   <div className="flex h-[specific-height] flex-col">
     {/* Fixed header */}

     <div>Fixed content</div>

     {/* Scrollable content */}

     <div className="flex-1 overflow-y-auto">Scrollable content</div>
   </div>;
   ```

5. When seeing ANY image with an overlay icon (especially in corners), ALWAYS implement the Lightbox component
